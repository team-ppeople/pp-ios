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
    // case reportPost
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
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .createPost:
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
        case .fetchDetailPosts(postId: let postId):
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
    
    func fetchDetailPosts(postId: Int) -> AnyPublisher<PostDetailResponse, MoyaError> {
        return provider
            .requestPublisher(.fetchDetailPosts(postId: postId))
            .map(PostDetailResponse.self)
            .eraseToAnyPublisher()
    }
    
    
}

