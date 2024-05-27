//
//  UserService.swift
//  pp
//
//  Created by 김지현 on 2024/05/07.
//

import Moya
import Combine


class UserService {
    static let shared = UserService()
    
    private var cancellables = Set<AnyCancellable>()
    
    lazy var provider = MoyaProvider<UserAPI>(plugins: [networkLogger])
    lazy var networkLogger = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    
    private init() {}
    
    
//MARK: - 선택한 이미지 AWS 서버에 전송
    func uploadImageToPresignedURL(presignedURL: String, imageData: Data) -> AnyPublisher<Void, APIError> {
        return provider.requestPublisher(.uploadImage(presignedURL: presignedURL, imageData: imageData))
            .tryMap { response in
                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    throw APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "Invalid response", instance: response.request?.url?.absoluteString ?? "")
                }
                print("Upload successful: \(response)")
                return Void()
            }
            .catch { error -> AnyPublisher<Void, APIError> in
                print("Upload error: \(error.localizedDescription)")
                return self.handleError(error, retry: { self.uploadImageToPresignedURL(presignedURL: presignedURL, imageData: imageData) })
            }
            .eraseToAnyPublisher()
    }

    //MARK: - 프로필 수정
    func updateUserProfile(userId: Int, nickname: String, imageUploads: [ImageUpload], presignedRequests: [PresignedUploadUrlRequests]) -> AnyPublisher<Void, APIError> {
        return getPresignedId(requestData: presignedRequests)
            .flatMap { presignedResponse -> AnyPublisher<Void, APIError> in
                let uploadPublishers = presignedResponse.data.presignedUploadFiles.enumerated().map { (index, file) in
                    self.uploadImageToPresignedURL(presignedURL: file.presignedUploadUrl, imageData: imageUploads[index].imageData)
                        .mapError { _ in APIError(type: "about:blank", title: "Upload Error", status: 500, detail: "Failed to upload image", instance: "/error-upload") }
                }
                
                return Publishers.MergeMany(uploadPublishers)
                    .collect()
                    .flatMap { _ -> AnyPublisher<Void, APIError> in
                        let fileUploadId = presignedResponse.data.presignedUploadFiles.first!.fileUploadId
                        let profile = EditProfileRequest(nickname: nickname, profileImageFileUploadId: fileUploadId)
                        return self.editUserInfo(userId: userId, profile: profile)
                    }
                    .eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<Void, APIError> in
                print("Error in updating user profile: \(error.status): \(error.title)")
                return Fail(error: APIError(type: "about:blank", title: "Comprehensive Error", status: 500, detail: "Failed to update user profile", instance: "/error")).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Presigned ID 요청
    func getPresignedId(requestData: [PresignedUploadUrlRequests]) -> AnyPublisher<PresignedIdResponse, APIError> {
        return provider
            .requestPublisher(.getPresignedId(requestData: requestData))
            .tryMap { response in
                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    throw APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "Invalid response", instance: response.request?.url?.absoluteString ?? "")
                }
                return try JSONDecoder().decode(PresignedIdResponse.self, from: response.data)
            }
            .catch { error -> AnyPublisher<PresignedIdResponse, APIError> in
                self.handleError(error, retry: { self.getPresignedId(requestData: requestData) })
            }
            .eraseToAnyPublisher()
    }

    // MARK: - 유저 정보 수정
    func editUserInfo(userId: Int, profile: EditProfileRequest) -> AnyPublisher<Void, APIError> {
        provider.requestPublisher(.editUserInfo(userId: userId, profile: profile))
            .map { _ in Void() }
            .catch { error in self.handleError(error, retry: { self.editUserInfo(userId: userId, profile: profile) }) }
            .eraseToAnyPublisher()
    }

    // MARK: - 유저 탈퇴
    func deleteUser(userId: Int) -> AnyPublisher<Void, APIError> {
        provider.requestPublisher(.deleteUser(userId: userId))
            .map { _ in Void() }
            .catch { error in self.handleError(error, retry: { self.deleteUser(userId: userId) }) }
            .eraseToAnyPublisher()
    }

    // MARK: - 유저 프로필 조회
    func fetchUserProfile(userId: Int) -> AnyPublisher<UserProfileResponse, APIError> {
        provider.requestPublisher(.fetchUserProfile(userId: userId))
            .tryMap { response in
                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    throw APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "Invalid response", instance: response.request?.url?.absoluteString ?? "")
                }
                return try JSONDecoder().decode(UserProfileResponse.self, from: response.data)
            }
            .catch { error in self.handleError(error, retry: { self.fetchUserProfile(userId: userId) }) }
            .eraseToAnyPublisher()
    }

    // MARK: - 유저 게시글 목록 조회
    func fetchUserPosts(userId: Int, limit: Int = 20, lastId: Int? = nil) -> AnyPublisher<UserPostsResponse, APIError> {
        provider.requestPublisher(.fetchUserPosts(userId: userId, limit: limit, lastId: lastId))
            .tryMap { response in
                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    throw APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "Invalid response", instance: response.request?.url?.absoluteString ?? "")
                }
                return try JSONDecoder().decode(UserPostsResponse.self, from: response.data)
            }
            .catch { error in self.handleError(error, retry: { self.fetchUserPosts(userId: userId, limit: limit, lastId: lastId) }) }
            .eraseToAnyPublisher()
    }

    func handleError<T>(_ error: Error, retry: @escaping () -> AnyPublisher<T, APIError>) -> AnyPublisher<T, APIError> {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                dump(response)
                if let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) {
                    if apiError.status == 400 {
                        return refreshTokenIfNeeded()
                            .flatMap { _ in retry() }
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: apiError).eraseToAnyPublisher()
                    }
                } else {
                    return Fail(error: APIError(type: "about:blank", title: "Decoding Error", status: 500, detail: "Error decoding error response", instance: response.request?.url?.absoluteString ?? "")).eraseToAnyPublisher()
                }
            default:
                return Fail(error: APIError(type: "about:blank", title: "Moya Error", status: 500, detail: "A Moya error occurred.", instance: "/error")).eraseToAnyPublisher()
            }
        } else {
            return Fail(error: APIError(type: "about:blank", title: "Non-Moya Error", status: 500, detail: error.localizedDescription, instance: "/error-non-moya")).eraseToAnyPublisher()
        }
    }

    func refreshTokenIfNeeded() -> AnyPublisher<Void, APIError> {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            return Fail(error: APIError(type: "about:blank", title: "Token Error", status: 401, detail: "No refresh token available.", instance: "/token-error")).eraseToAnyPublisher()
        }

        let tokenRequest = TokenRequest(refreshToken: refreshToken)
        return AuthService.shared.refreshToken(tokenRequest: tokenRequest)
            .map { tokenResponse -> Void in
                UserDefaults.standard.set(tokenResponse.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(tokenResponse.refreshToken, forKey: "refreshToken")
                return Void()
            }
            .mapError { error -> APIError in
                return APIError(type: "about:blank", title: "Token Refresh Error", status: error.status, detail: "Failed to refresh token.", instance: "/token-refresh-fail")
            }
            .eraseToAnyPublisher()
    }
}
