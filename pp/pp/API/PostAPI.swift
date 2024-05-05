//
//  PostEndpoint.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation
import Combine
import Moya

//MARK: - Moya 정의
enum CommunityAPI {
    // Todo: createPost 에 image id 값으로 변경해서 같이 송신해야함
    case createPost(post: PostRequest)
    case fetchPostsLists(limit: Int, lastId: Int?)
    case fetchDetailPosts(postId:Int)
    case reportPost(postId: Int)
    case thumbsUp(postId: Int)
    case thumbs_sideways(postId:Int)
    case fetchComments(postId:Int,limit:Int,lastId:Int?)
    case writeComments(postId:Int,comment:CommentRequest)
    case reportComment(commentId:Int)
    
}

extension CommunityAPI: TargetType {
    var path: String {
        switch self {
        case .createPost, .fetchPostsLists:
            return "posts"
        case .fetchDetailPosts(let postId):
            return "posts/\(postId)"
        case .reportPost(let postId):
            return "posts/\(postId)/report"
        case .thumbsUp(let postId):
            return "posts/\(postId)/thumbs-up"
        case .thumbs_sideways(let postId):
            return "posts/\(postId)/thumbs_sideways"
        case .fetchComments(let postId,_,_),.writeComments(let postId,_):
            return "posts/\(postId)/comments"
        case .reportComment(let commentId):
            return "comments/\(commentId)/report"
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .createPost,.reportPost,.thumbsUp,.thumbs_sideways,.writeComments:
            return .post
        case .fetchPostsLists,.fetchDetailPosts,.fetchComments,.reportComment:
            return .get
            
        }
    }
    
    
    var task: Moya.Task {
        switch self {
        case .createPost(let post):
            return .requestJSONEncodable(post)
        case .fetchPostsLists(let limit, let lastId):
            let adjustedLimit = max(10, min(limit, 100)) // 최소값 10, 최대값 100 적용
            var parameters: [String: Any] = ["limit": adjustedLimit]
            if let lastId = lastId {
                parameters["lastId"] = lastId - 1
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .fetchDetailPosts, .reportPost,.thumbsUp,.thumbs_sideways,.reportComment:
            return .requestPlain
            
            
        case .fetchComments(let postId, let limit, let lastId):
            let adjustedLimit = max(10, min(limit, 100)) // 최소값 10, 최대값 100 적용
            var parameters: [String: Any] = ["limit": adjustedLimit]
            if let lastId = lastId {
                parameters["lastId"] = lastId - 1
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .writeComments(_, let comment):
                return .requestJSONEncodable(comment)
            }
   
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL {
        return URL(string: BaseUrl.server.rawValue)!
    }
    
}


//MARK: - Community API 통신
class CommunityService {
    static let shared = CommunityService()
    private let provider = MoyaProvider<CommunityAPI>()
    
    private init() {}
    
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
