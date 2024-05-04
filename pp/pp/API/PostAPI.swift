//
//  PostEndpoint.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation
import Combine
import Moya

enum CommunityAPI {
    case createPost(post: PostRequest)
    case fetchPostsLists(limit: Int, lastId: Int?)
    case fetchDetailPosts(postId:Int)
    case reportPost(postId: Int)
    // case likesPost
    // case thumbsUp
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
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .createPost,.reportPost:
            return .post
        case .fetchPostsLists,.fetchDetailPosts:
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
        case .fetchDetailPosts, .reportPost:
            return .requestPlain
            
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL {
        return URL(string: "https://pp-api-kro.kr/api/v1")!
    }
    
}


class CommunityService {
    static let shared = CommunityService()
    private let provider = MoyaProvider<CommunityAPI>()
    
    private init() {}
    
    //MARK: - 커뮤니티 게시글 작성
    func createPost(post: PostRequest) -> AnyPublisher<Void , MoyaError > {
        
        return provider
            .requestPublisher(.createPost(post: post))
            .map {_ in}
            .eraseToAnyPublisher()
        
    }
    
    //MARK: - 커뮤니티 게시글 목록 조회
    
    func fetchPosts(limit: Int = 20, lastId: Int?) -> AnyPublisher<PostsResponse, MoyaError> {
        return provider
            .requestPublisher(.fetchPostsLists(limit: limit, lastId: lastId))
            .map(PostsResponse.self)
            .eraseToAnyPublisher()
    }
    
    //MARK: - 커뮤니티 게시글 상세 조회
    
    func fetchDetailPosts(postId: Int) -> AnyPublisher<PostDetailResponse, APIError> {
        return provider
            .requestPublisher(.fetchDetailPosts(postId: postId))
            .mapError { moyaError -> APIError in
             // MoyaError를 APIError로 변환
                if let response = moyaError.response, let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) {
                    print("API Error Occurred: \(apiError.title) - \(apiError.detail)")
                    return apiError
                } else {
                    return APIError(type: "about:blank", title: "Unknown Error", status: 500, detail: "An unknown error occurred.", instance: "/api/v1/example")
                }
            }
            .tryMap { response -> PostDetailResponse in
                // 응답 데이터를 PostDetailResponse로 디코딩
                guard let statusCode = (response.response)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                    let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
                    throw apiError
                }
                return try JSONDecoder().decode(PostDetailResponse.self, from: response.data)
            }
            .mapError { error in
                //  tryMap에서 발생한 오류를 처리
                if let apiError = error as? APIError {
                    print("Handling Error: \(apiError.title) - \(apiError.detail)")
                    return apiError
                } else if let moyaError = error as? MoyaError, let response = moyaError.response, let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) {
                    print("Decoding Error: \(apiError.title) - \(apiError.detail)")
                    return apiError
                } else {
                    return APIError(type: "about:blank", title: "Error decoding", status: 500, detail: "Error decoding response", instance: "/api/v1/example")
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 게시글 신고
    func reportPost(postId: Int) -> AnyPublisher<Void, MoyaError> {
        return provider
            .requestPublisher(.reportPost(postId: postId))
            .mapError { error -> MoyaError in

                if case let MoyaError.statusCode(response) = error, response.statusCode >= 400 {
  
                }
                return error
            }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
}



