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
    // case likesPost
    case thumbsUp(postId: Int)
    // case thumbs_sideways
    // case fetchComments
    // case writeComments
    // case reportComment
    
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
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .createPost,.reportPost:
            return .post
        case .fetchPostsLists,.fetchDetailPosts,.thumbsUp:
            return .get
            
        }
    }
    
    
    var task: Moya.Task {
        switch self {
        case .createPost(let post):
            return .requestJSONEncodable(post)
        case .fetchPostsLists(let limit, let lastId):
            var parameters: [String: Any] = ["limit": limit]
            if let lastId = lastId {
                parameters["lastId"] = lastId - 1
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .fetchDetailPosts, .reportPost,.thumbsUp:
            return .requestPlain
            
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
