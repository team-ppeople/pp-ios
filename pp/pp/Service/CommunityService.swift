//
//  CommunityService.swift
//  pp
//
//  Created by 김지현 on 2024/05/07.
//

import Moya
import Combine


//MARK: - Community API 통신
class CommunityService {
    static let shared = CommunityService()
    //private let provider = MoyaProvider<CommunityAPI>()
    private var cancellables = Set<AnyCancellable>()
    
    lazy var provider = MoyaProvider<CommunityAPI>(plugins: [networkLogger])
    lazy var networkLogger = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    private init() {}
    
//    func uploadPostWithImages(title: String, content: String, imageData: [PresignedIdRequest]) -> AnyPublisher<Void, APIError> {
//           //  사진 업로드 가능 ID를 획득
//        return getPresignedId(requestData: imageData)
//            .flatMap { presignedResponse -> AnyPublisher<Void, APIError> in
//                // 응답으로 받은 파일 ID들을 추출
//                let imageIds = presignedResponse.data.presignedUploadUrlResponses.map { $0.fileUploadId }
//                // 추출된 ID들을 게시글 요청에 포함
//                let postRequest = PostRequest(title: title, content: content, postImageFileUploadIds: imageIds)
//                return self.createPost(post: postRequest)
//            }
//            .eraseToAnyPublisher()
//    }
   

    //MARK: - 사진 업로드 가능 ID 검증\
    
    
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
//    func getPresignedId(requestData: [PresignedUploadUrlRequests]) -> AnyPublisher<PresignedIdResponse, APIError> {
//        return provider
//            .requestPublisher(.getPresignedId(requestData: requestData))
//            .mapError(handleError2)
//            .tryMap { response in
//                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
//                    let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
//                    throw apiError
//                }
//                return try JSONDecoder().decode(PresignedIdResponse.self, from: response.data)
//            }
//            .mapError(handleError2)
//            .eraseToAnyPublisher()
//    }
    //MARK: - 커뮤니티 게시글 작성
//    
//    func createPost(post: PostRequest) -> AnyPublisher<Void, APIError> {
//        return provider
//            .requestPublisher(.createPost(post: post))
//            .map { _ in Void() }
//            .catch { error in self.handleError(error, retry: { self.createPost(post: post) }) }
//            .eraseToAnyPublisher()
//    }

    //MARK: - 커뮤니티 게시글 목록 조회
    func fetchPosts(limit: Int = 20, lastId: Int?) -> AnyPublisher<PostsResponse, APIError> {
        return provider
            .requestPublisher(.fetchPostsLists(limit: limit, lastId: lastId))
            .tryMap { response -> PostsResponse in
                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    throw APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "Invalid response", instance: response.request?.url?.absoluteString ?? "")
                }
                return try JSONDecoder().decode(PostsResponse.self, from: response.data)
            }
            .catch { error in self.handleError(error, retry: { self.fetchPosts(limit: limit, lastId: lastId) }) }
            .eraseToAnyPublisher()
    }

    //MARK: - 커뮤니티 게시글 상세 조회
//    func fetchDetailPosts(postId: Int) -> AnyPublisher<PostDetailResponse, APIError> {
//        return provider
//            .requestPublisher(.fetchDetailPosts(postId: postId))
//            .tryMap { response -> PostDetailResponse in
//                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
//                    throw APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "Invalid response", instance: response.request?.url?.absoluteString ?? "")
//                }
//                return try JSONDecoder().decode(PostDetailResponse.self, from: response.data)
//            }
//            .catch { error in self.handleError(error, retry: { self.fetchDetailPosts(postId: postId) }) }
//            .eraseToAnyPublisher()
//    }

    // MARK: - 게시글 신고
//    func reportPost(postId: Int) -> AnyPublisher<Void, APIError> {
//        return provider
//            .requestPublisher(.reportPost(postId: postId))
//            .map { _ in Void() }
//            .catch { error in self.handleError(error, retry: { self.reportPost(postId: postId) }) }
//            .eraseToAnyPublisher()
//    }

    // MARK: - 게시글 좋아요
//    func thumbsUpPost(postId: Int) -> AnyPublisher<Void, APIError> {
//        return provider
//            .requestPublisher(.thumbsUp(postId: postId))
//            .map { _ in Void() }
//            .catch { error in self.handleError(error, retry: { self.thumbsUpPost(postId: postId) }) }
//            .eraseToAnyPublisher()
//    }

    // MARK: - 게시글 좋아요 취소
//    func thumbsSidewayPost(postId: Int) -> AnyPublisher<Void, APIError> {
//        return provider
//            .requestPublisher(.thumbs_sideways(postId: postId))
//            .map { _ in Void() }
//            .catch { error in self.handleError(error, retry: { self.thumbsSidewayPost(postId: postId) }) }
//            .eraseToAnyPublisher()
//    }

    // MARK: - 게시글 댓글 목록 조회
//    func fetchComments(postId: Int, limit: Int = 20, lastId: Int? = nil) -> AnyPublisher<CommentsResponse, APIError> {
//        return provider
//            .requestPublisher(.fetchComments(postId: postId, limit: limit, lastId: lastId))
//            .tryMap { response -> CommentsResponse in
//                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
//                    throw APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "Invalid response", instance: response.request?.url?.absoluteString ?? "")
//                }
//                return try JSONDecoder().decode(CommentsResponse.self, from: response.data)
//            }
//            .catch { error in self.handleError(error, retry: { self.fetchComments(postId: postId, limit: limit, lastId: lastId) }) }
//            .eraseToAnyPublisher()
//    }

    //MARK: - 커뮤니티 댓글 작성
//    func writeComment(postId: Int, comment: CommentRequest) -> AnyPublisher<Void, APIError> {
//        return provider
//            .requestPublisher(.writeComments(postId: postId, comment: comment))
//            .map { _ in Void() }
//            .catch { error in self.handleError(error, retry: { self.writeComment(postId: postId, comment: comment) }) }
//            .eraseToAnyPublisher()
//    }

    //MARK: - 댓글 신고
//    func reportComments(commentId: Int) -> AnyPublisher<Void, APIError> {
//        return provider
//            .requestPublisher(.reportComment(commentId: commentId))
//            .map { _ in Void() }
//            .catch { error in self.handleError(error, retry: { self.reportComments(commentId: commentId) }) }
//            .eraseToAnyPublisher()
//    }
}

//MARK: - Error 핸들링 함수 정의
extension CommunityService {
    func handleError<T>(_ error: Error, retry: @escaping () -> AnyPublisher<T, APIError>) -> AnyPublisher<T, APIError> {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                dump(response)
                if let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) {
                    if apiError.status == 400 {
                        // 토큰 갱신 시도
                        return refreshTokenIfNeeded()
                            .flatMap { _ in retry() }
                            .eraseToAnyPublisher()
                    } else {
                        // 다른 에러는 그대로 반환
                        return Fail(error: apiError).eraseToAnyPublisher()
                    }
                } else {
                    // 디코딩 실패 시 기본 에러 반환
                    return Fail(error: APIError(type: "about:blank", title: "Decoding Error", status: 500, detail: "Error decoding error response", instance: response.request?.url?.absoluteString ?? "")).eraseToAnyPublisher()
                }
            default:
                return Fail(error: APIError(type: "about:blank", title: "Moya Error", status: 500, detail: "A Moya error occurred.", instance: "/error")).eraseToAnyPublisher()
            }
        } else {
            print("Received non-Moya error: \(type(of: error)) - \(error.localizedDescription)")
            // MoyaError가 아닌 경우
            return Fail(error: APIError(type: "about:blank", title: "Non-Moya Error", status: 500, detail: error.localizedDescription, instance: "/error-non-moya")).eraseToAnyPublisher()
        }
    }
//    func handleError<T>(_ error: Error, retry: @escaping () -> AnyPublisher<T, APIError>) -> AnyPublisher<T, APIError> {
//        if let moyaError = error as? MoyaError {
//            switch moyaError {
//            case .statusCode(let response):
//                if let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) {
//                
//                    if apiError.status == 400 {
//                        // 토큰 갱신 시도
//                        return refreshTokenIfNeeded()
//                            .flatMap { _ in
//                        // 토큰 갱신 성공 후 재시도
//                                return retry()
//                            }
//                            .eraseToAnyPublisher()
//                    } else {
//                        // 다른 에러는 그대로 반환
//                        return Fail(error: apiError).eraseToAnyPublisher()
//                    }
//                } else {
//                        // 디코딩 실패 시 기본 에러 반환
//                    return Fail(error: APIError(type: "about:blank", title: "Decoding Error", status: 500, detail: "Error decoding error response", instance: response.request?.url?.absoluteString ?? "")).eraseToAnyPublisher()
//                }
//            default:
//                        // MoyaError가 statusCode 외의 경우
//                return Fail(error: APIError(type: "about:blank", title: "Unknown Error", status: 500, detail: "An unexpected error occurred.", instance: "/error")).eraseToAnyPublisher()
//                print("Received error type: \(type(of: error))")
//            }
//        }
//        // MoyaError가 아닌 경우
//        return Fail(error: APIError(type: "about:blank", title: "Unknown Error", status: 500, detail: "An unexpected error occurred.", instance: "/error2222")).eraseToAnyPublisher()
//    }
    
    //MARK: - 토큰 재발급 요청 
    func refreshTokenIfNeeded() -> AnyPublisher<Void, APIError> {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            // 토큰이 존재하지 않을 때 처리
            return Fail(error: APIError(type: "about:blank", title: "Token Error", status: 401, detail: "No refresh token available.", instance: "/token-error")).eraseToAnyPublisher()
        }

        var tokenRequest = TokenRequest(refreshToken: refreshToken)
        return AuthService.shared.refreshToken(tokenRequest: tokenRequest)
            .map { tokenResponse -> Void in
                // 성공적으로 토큰을 갱신했을 때 필요한 처리
                UserDefaults.standard.set(tokenResponse.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(tokenResponse.refreshToken, forKey: "refreshToken")
                return Void()
            }
            .mapError { error -> APIError in
                // 토큰 갱신 실패 시 에러 처리
                return APIError(type: "about:blank", title: "Token Refresh Error", status: error.status, detail: "Failed to refresh token.", instance: "/token-refresh-fail")
            }
            .eraseToAnyPublisher()
    }
    
}




extension CommunityService {
    private func handleError2(_ error: Error) -> APIError {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                if let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) {
                    return apiError
                }
                return APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "An error occurred.", instance: response.request?.url?.absoluteString ?? "")
            default:
                return APIError(type: "about:blank", title: "Network Error", status: 500, detail: "A network error occurred.", instance: "/error")
            }
        }
        return APIError(type: "about:blank", title: "Unknown Error", status: 500, detail: "An unexpected error occurred.", instance: "/error")
    }
}




