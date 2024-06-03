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
    
    
    // MARK: - 등록된 피피 회원 유저인지 여부 체크
    func checkRegisteredUser(client: Client, idToken: String) -> AnyPublisher<CheckRegisteredUserResponse, APIError> {
        return provider
            .requestPublisher(.checkRegisteredUser(client: client, idToken: idToken))
            .tryMap { response -> CheckRegisteredUserResponse in
                return try JSONDecoder().decode(CheckRegisteredUserResponse.self, from: response.data)
            }
            .mapError(Utils.handleError)
            .eraseToAnyPublisher()
    }
    
    
    
    //MARK: - 선택한 이미지 AWS 서버에 전송
    func uploadImageToPresignedURL(presignedURL: String, imageData: Data) -> AnyPublisher<Void, APIError> {
        return provider.requestPublisher(.uploadImage(presignedURL: presignedURL, imageData: imageData))
            .map { _ in Void() }
            .mapError(Utils.handleError)
            .eraseToAnyPublisher()
    }
    
    //MARK: - 프로필 수정
    //        func updateUserProfile(userId: Int, nickname: String, imageUploads: [ImageUpload], presignedRequests: [PresignedUploadUrlRequests]) -> AnyPublisher<Void, APIError> {
    //            return getPresignedId(requestData: presignedRequests)
    //                .flatMap { presignedResponse -> AnyPublisher<Void, APIError> in
    //                    let uploadPublishers = presignedResponse.data.presignedUploadFiles.enumerated().map { (index, file) in
    //                        self.uploadImageToPresignedURL(presignedURL: file.presignedUploadUrl, imageData: imageUploads[index].imageData)
    //                            .mapError { _ in APIError(type: "about:blank", title: "Upload Error", status: 500, detail: "Failed to upload image", instance: "/error-upload") }
    //                    }
    //
    //                    return Publishers.MergeMany(uploadPublishers)
    //                        .collect()
    //                        .flatMap { _ -> AnyPublisher<Void, APIError> in
    //                            let fileUploadId = presignedResponse.data.presignedUploadFiles.first!.fileUploadId
    //                            let profile = EditProfileRequest(nickname: nickname, profileImageFileUploadId: fileUploadId)
    //                            return self.editUserInfo(userId: userId, profile: profile)
    //                        }
    //                        .eraseToAnyPublisher()
    //                }
    //                .catch { error -> AnyPublisher<Void, APIError> in
    //                    print("Error in updating user profile: \(error.status): \(error.title)")
    //                    return Fail(error: APIError(type: "about:blank", title: "Comprehensive Error", status: 500, detail: "Failed to update user profile", instance: "/error")).eraseToAnyPublisher()
    //                }
    //                .eraseToAnyPublisher()
    //        }
    func updateUserProfile(userId: Int, nickname: String, imageUploads: [ImageUpload], presignedRequests: [PresignedUploadUrlRequests]) -> AnyPublisher<Void, APIError> {
        return getPresignedId(requestData: presignedRequests)
            .flatMap { presignedResponse -> AnyPublisher<Void, APIError> in
                let uploadPublishers = presignedResponse.data.presignedUploadFiles.enumerated().map { (index, file) in
                    self.uploadImageToPresignedURL(presignedURL: file.presignedUploadUrl, imageData: imageUploads[index].imageData)
                        .mapError(Utils.handleError)
                }
                
                return Publishers.MergeMany(uploadPublishers)
                    .collect()
                    .flatMap { _ -> AnyPublisher<Void, APIError> in
                        guard let fileUploadId = presignedResponse.data.presignedUploadFiles.first?.fileUploadId else {
                            return Fail(error: APIError(description: "No file upload ID found", statusCode: 500, instance: "/error-upload-id")).eraseToAnyPublisher()
                        }
                        let profile = EditProfileRequest(nickname: nickname, profileImageFileUploadId: fileUploadId)
                        return self.editUserInfo(userId: userId, profile: profile)
                    }
                    .eraseToAnyPublisher()
            }
            .mapError(Utils.handleError)
            .eraseToAnyPublisher()
    }
    
    
    
    // MARK: - Presigned ID 요청
    func getPresignedId(requestData: [PresignedUploadUrlRequests]) -> AnyPublisher<PresignedIdResponse, APIError> {
        return provider
            .requestPublisher(.getPresignedId(requestData: requestData))
            .tryMap { response in
                return try JSONDecoder().decode(PresignedIdResponse.self, from: response.data)
            }
            .mapError(Utils.handleError)
            .eraseToAnyPublisher()
    }
    
    
    
    
    
    
    
    //MARK: - 유저 정보 수정
    func editUserInfo(userId: Int, profile: EditProfileRequest) -> AnyPublisher<Void, APIError> {
        provider.requestPublisher(.editUserInfo(userId: userId, profile: profile))
            .map { _ in Void() }
            .mapError(Utils.handleError)
            .eraseToAnyPublisher()
    }
    
    //MARK: - 유저 탈퇴
    func deleteUser(userId:Int) -> AnyPublisher<Void,APIError> {
        provider.requestPublisher(.deleteUser(userId: userId))
            .map { _ in Void() }
            .mapError(Utils.handleError)
            .eraseToAnyPublisher()
    }
    
    //MARK: - 유저 프로필 조회
    func fetchUserProfile(userId: Int) -> AnyPublisher<UserProfileResponse, APIError> {
        provider.requestPublisher(.fetchUserProfile(userId: userId))
            .tryMap { response in
                return try JSONDecoder().decode(UserProfileResponse.self, from: response.data)
            }
            .mapError(Utils.handleError)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 유저 게시글 목록 조회
    func fetchUserPosts(userId: Int, limit: Int = 20, lastId: Int? = nil) -> AnyPublisher<UserPostsResponse, APIError> {
        provider.requestPublisher(.fetchUserPosts(userId: userId, limit: limit, lastId: lastId))
            .tryMap { response in
                return try JSONDecoder().decode(UserPostsResponse.self, from: response.data)
            }
            .mapError(Utils.handleError)
            .eraseToAnyPublisher()
    }
    
    
    
    // MARK: - 공지사항 조회
    func fetchNotices(limit: Int = 20, lastId: Int? = nil) -> AnyPublisher<NoticeResponse, APIError> {
        provider.requestPublisher(.fetchNotices(limit: limit,lastId: lastId))
            .tryMap { response in
                return try JSONDecoder().decode(NoticeResponse.self, from: response.data)
            }
            .mapError(Utils.handleError)
            .eraseToAnyPublisher()
    }
    
    
    
}


