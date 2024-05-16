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
    
    case getPresignedId(requestData: [PresignedIdRequest])
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
            return "/posts"
        case .fetchDetailPosts(let postId):
            return "/posts/\(postId)"
        case .reportPost(let postId):
            return "/posts/\(postId)/report"
        case .thumbsUp(let postId):
            return "/posts/\(postId)/thumbs-up"
        case .thumbs_sideways(let postId):
            return "/posts/\(postId)/thumbs_sideways"
        case .fetchComments(let postId,_,_),.writeComments(let postId,_):
            return "/posts/\(postId)/comments"
        case .reportComment(let commentId):
            return "/comments/\(commentId)/report"
        case .getPresignedId:
                return "/api/v1/presigned-urls/upload"
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .createPost,.reportPost,.thumbsUp,.thumbs_sideways,.writeComments,.getPresignedId:
            return .post
        case .fetchPostsLists,.fetchDetailPosts,.fetchComments,.reportComment:
            return .get
            
        }
    }
    
    
    var task: Moya.Task {
        switch self {
        case .getPresignedId(let requestData):
            return .requestJSONEncodable(requestData)
       
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
        let accessToken = UserDefaults.standard.string(forKey: "AccessToken") ?? ""
        
        print("accessToken is \(accessToken)")
        return ["accept": "application/json",
                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json"
                ]
        
    }
    
    var baseURL: URL {
        return URL(string: Url.server.rawValue)!
    }
    
}


