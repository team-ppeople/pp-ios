//
//  UserEndpoint.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Moya

enum UserAPI {
    case checkRegisteredUser(client: Client, idToken: String) // 로그인 회원 등록 여부 확인
    case editUserInfo(userId:Int,profile:EditProfileRequest)// 유저 정보 수정
    case deleteUser(userId:Int) // 유저 탈퇴
    case fetchUserProfile(userId:Int) // 유저 프로필 조회
    case fetchUserPosts(userId: Int, limit: Int, lastId: Int?)// 유저 커뮤니티 게시글 목록 조회
}

extension UserAPI : TargetType {
    var baseURL: URL { URL(string: Url.server.rawValue)! }
    
    var path: String {
        switch self {
        case let .checkRegisteredUser(client, _):
            return "/api/v1/oauth2/\(client)/users/registered"
        case .editUserInfo(let userId,_):
            return "/api/v1/users/\(userId)"
        case .deleteUser(let userId):
            return "/api/v1/users/\(userId)"
        case .fetchUserProfile(let userId):
                   return "/api/v1/users/\(userId)/profiles"
        case .fetchUserPosts(let userId, _, _):
                    return "/api/v1/users/\(userId)/posts"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .checkRegisteredUser:
            return .post
        case .editUserInfo:
            return .patch
        case .deleteUser:
            return .delete
        case .fetchUserProfile,.fetchUserPosts:
            return .get
        }
    }
    
    var sampleData: Data {
        return .init()
    }
    
    var task: Task {
        switch self {
        case let .checkRegisteredUser(_, idToken):
            return .requestParameters(parameters: ["idToken": idToken], encoding: URLEncoding.default)
        case .editUserInfo(_, let profile):
            return .requestJSONEncodable(profile)
        case .deleteUser(userId: let userId):
            return .requestPlain
        case .fetchUserProfile:
            return .requestPlain
        case let .fetchUserPosts(_, limit, lastId):
            let adjustedLimit = max(10, min(limit, 100)) // 최소값 10, 최대값 100 적용
            var parameters: [String: Any] = ["limit": adjustedLimit]
            if let lastId = lastId {
                parameters["lastId"] = lastId - 1
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .checkRegisteredUser:
            return [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
        default:
            let accessToken = UserDefaults.standard.string(forKey: "AccessToken") ?? ""
            return [
                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json"
            ]
        }
    }
    
    var validationType: ValidationType { .successCodes }
}

enum Client: String {
    case kakao = "kakao"
    case apple = "apple"
}
