//
//  PostEndpoint.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation
import Moya

enum CommunityAPI {
    case getPresignedId(requestData: [PresignedUploadUrlRequests])
    case createPost(post: PostRequest)
    case fetchPostsLists(limit: Int, lastId: Int?)
    case fetchDetailPosts(postId: Int)
    case reportPost(postId: Int)
    case thumbsUp(postId: Int)
    case thumbs_sideways(postId: Int)
    case fetchComments(postId: Int, limit: Int, lastId: Int?)
    case writeComments(postId: Int, comment: CommentRequest)
    case reportComment(commentId: Int)
    case uploadImage(presignedURL: String, imageData: Data)
}

extension CommunityAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .uploadImage(let presignedURL, _):
            return URL(string: presignedURL)!
        default:
            return URL(string: Url.server.rawValue)!
        }
    }
    
    var path: String {
        switch self {
        case .createPost, .fetchPostsLists:
            return "/api/v1/posts"
        case .fetchDetailPosts(let postId):
            return "/api/v1/posts/\(postId)"
        case .reportPost(let postId):
            return "/api/v1/posts/\(postId)/report"
        case .thumbsUp(let postId):
            return "/api/v1/posts/\(postId)/thumbs-up"
        case .thumbs_sideways(let postId):
            return "/api/v1/posts/\(postId)/thumbs-sideways"
        case .fetchComments(let postId, _, _), .writeComments(let postId, _):
            return "/api/v1/posts/\(postId)/comments"
        case .reportComment(let commentId):
            return "/api/v1/comments/\(commentId)/report"
        case .getPresignedId:
            return "/api/v1/presigned-urls/upload"
        case .uploadImage:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createPost, .reportPost, .thumbsUp, .thumbs_sideways, .writeComments, .getPresignedId, .reportComment:
            return .post
        case .fetchPostsLists, .fetchDetailPosts, .fetchComments:
            return .get
        case .uploadImage:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case .getPresignedId(let requestData):
            let requestDataObject = PresignedUploadUrlRequestData(presignedUploadUrlRequests: requestData)
            return .requestJSONEncodable(requestDataObject)
        case .createPost(let post):
            return .requestJSONEncodable(post)
        case .fetchPostsLists(let limit, let lastId):
            let adjustedLimit = max(10, min(limit, 100)) // 최소값 10, 최대값 100 적용
            var parameters: [String: Any] = ["limit": adjustedLimit]
            if let lastId = lastId {
                parameters["lastId"] = lastId - 1
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .fetchDetailPosts, .reportPost, .thumbsUp, .thumbs_sideways, .reportComment:
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
        case .uploadImage(_, let imageData):
            return .requestData(imageData)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .uploadImage:
            return ["Content-Type": "image/jpeg"]
        default:
            let accessToken = UserDefaults.standard.string(forKey: "AccessToken") ?? ""
            return [
                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json"
            ]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
