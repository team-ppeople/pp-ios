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
    private let provider = MoyaProvider<CommunityAPI>()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func uploadPostWithImages(title: String, content: String, imageData: [PresignedIdRequest]) -> AnyPublisher<Void, APIError> {
        // 먼저 사진 업로드 가능 ID를 얻습니다.
        return getPresignedId(requestData: imageData)
            .flatMap { presignedResponse -> AnyPublisher<Void, APIError> in
                // 응답으로 받은 파일 ID들을 추출합니다.
                let imageIds = presignedResponse.data.presignedUploadUrlResponses.map { $0.fileUploadId }
                // 추출된 ID들을 게시글 요청에 포함시킵니다.
                let postRequest = PostRequest(title: title, content: content, postImageFileUploadIds: imageIds)
                return self.createPost(post: postRequest)
            }
            .eraseToAnyPublisher()
    }
   

    //MARK: - 사진 업로드 가능 ID 검증
   
    func getPresignedId(requestData: [PresignedIdRequest]) -> AnyPublisher<PresignedIdResponse, APIError> {
        return provider
            .requestPublisher(.getPresignedId(requestData: requestData))
            .mapError(handleError)
            .tryMap { response in
                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
                    throw apiError
                }
                return try JSONDecoder().decode(PresignedIdResponse.self, from: response.data)
            }
            .mapError(handleError)
            .eraseToAnyPublisher()
    }
    //MARK: - 커뮤니티 게시글 작성
    func createPost(post: PostRequest) -> AnyPublisher<Void , APIError > {
        return provider
            .requestPublisher(.createPost(post: post))
            .mapError (handleError)
            .map {_ in}
            .mapError (handleError)
            .eraseToAnyPublisher()
        
    }
    
    //MARK: - 커뮤니티 게시글 목록 조회
    func fetchPosts(limit: Int = 20, lastId: Int?) -> AnyPublisher<PostsResponse, APIError> {
        return provider
            .requestPublisher(.fetchPostsLists(limit: limit, lastId: lastId))
            .mapError (handleError)
            .tryMap { response -> PostsResponse in
                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
                    throw apiError
                }
                return try JSONDecoder().decode(PostsResponse.self, from: response.data)
            }
            .mapError(handleError)
            .eraseToAnyPublisher()
    }
    //MARK: - 커뮤니티 게시글 상세 조회
    
    func fetchDetailPosts(postId: Int) -> AnyPublisher<PostDetailResponse, APIError> {
        return provider
            .requestPublisher(.fetchDetailPosts(postId: postId))
            .mapError(handleError)
            .tryMap { response -> PostDetailResponse in
                // 응답 데이터를 PostDetailResponse로 디코딩
                guard let statusCode = (response.response)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
                    throw apiError
                }
                return try JSONDecoder().decode(PostDetailResponse.self, from: response.data)
            }
            .mapError(handleError)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 게시글 신고
    func reportPost(postId: Int) -> AnyPublisher<Void, APIError> {
        return provider
            .requestPublisher(.reportPost(postId: postId))
            .mapError (handleError)
            .map { _ in }
            .mapError (handleError)
            .eraseToAnyPublisher()
    }
    // MARK: - 게시글 좋아요
    func thumbsUpPost(postId: Int) -> AnyPublisher<Void,APIError> {
        return provider
            .requestPublisher(.thumbsUp(postId: postId))
            .mapError(handleError)
            .map { _ in}
            .mapError(handleError)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 게시글 좋아요 취소
    func thumbsSidewayPost(postId:Int) -> AnyPublisher<Void,APIError> {
        return provider
            .requestPublisher(.thumbs_sideways(postId: postId))
            .mapError(handleError)
            .map {_ in}
            .mapError(handleError)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 게시글 댓글 목록 조회
    
    func fetchComments(postId: Int, limit: Int = 20, lastId: Int? = nil) -> AnyPublisher<CommentsResponse, APIError> {
        return provider
            .requestPublisher(.fetchComments(postId: postId, limit: limit, lastId: lastId))
            .mapError(handleError)
            .tryMap { response -> CommentsResponse in
                guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
                    throw apiError
                }
                return try JSONDecoder().decode(CommentsResponse.self, from: response.data)
            }
            .mapError(handleError)
            .eraseToAnyPublisher()
    }
    //MARK: - 커뮤니티 댓글 작성
    func writeComment(postId:Int,comment: CommentRequest) -> AnyPublisher<Void , APIError > {
        
        return provider
            .requestPublisher(.writeComments(postId: postId, comment: comment))
            .mapError (handleError)
            .map {_ in}
            .mapError (handleError)
            .eraseToAnyPublisher()
        
    }
    //MARK: - 댓글 신고
    
    func reportComments(commentId:Int) -> AnyPublisher<Void,APIError> {
        return provider
            .requestPublisher(.reportComment(commentId: commentId))
            .mapError (handleError)
            .map { _ in }
            .mapError (handleError)
            .eraseToAnyPublisher()
    }
}

//MARK: - Error 핸들링 함수 정의
extension CommunityService {
    private func handleError(_ error: Error) -> APIError {
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
