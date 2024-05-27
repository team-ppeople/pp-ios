//
//  UserEndpoint.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Moya

enum UserAPI {
    case getPresignedId(requestData: [PresignedUploadUrlRequests])
    case checkRegisteredUser(client: Client, idToken: String) // 로그인 회원 등록 여부 확인
    case editUserInfo(userId:Int,profile:EditProfileRequest)// 유저 정보 수정
    case deleteUser(userId:Int) // 유저 탈퇴
    case fetchUserProfile(userId:Int) // 유저 프로필 조회
    case fetchUserPosts(userId: Int, limit: Int, lastId: Int?)// 유저 커뮤니티 게시글 목록 조회
    case uploadImage(presignedURL: String, imageData: Data)
}

extension UserAPI: TargetType {
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
        case .checkRegisteredUser(let client, _):
            return "/api/v1/oauth2/\(client)/users/registered"
        case .editUserInfo(let userId, _):
            return "/api/v1/users/\(userId)"
        case .deleteUser(let userId):
            return "/api/v1/users/\(userId)"
        case .fetchUserProfile(let userId):
            return "/api/v1/users/\(userId)/profiles"
        case .fetchUserPosts(let userId, _, _):
            return "/api/v1/users/\(userId)/posts"
        case .getPresignedId:
            return "/api/v1/presigned-urls/upload"
        case .uploadImage:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .checkRegisteredUser, .getPresignedId:
            return .post
        case .editUserInfo:
            return .patch
        case .deleteUser:
            return .delete
        case .fetchUserProfile, .fetchUserPosts:
            return .get
        case .uploadImage:
            return .put
        }
    }
    
    var sampleData: Data {
        return .init()
    }
    
    var task: Task {
        switch self {
        case .getPresignedId(let requestData):
            let requestDataObject = PresignedUploadUrlRequestData(presignedUploadUrlRequests: requestData)
            return .requestJSONEncodable(requestDataObject)
        case .checkRegisteredUser(_, let idToken):
            return .requestParameters(parameters: ["idToken": idToken], encoding: URLEncoding.default)
        case .editUserInfo(_, let profile):
            return .requestJSONEncodable(profile)
        case .deleteUser, .fetchUserProfile:
            return .requestPlain
        case .fetchUserPosts(_, let limit, let lastId):
            let adjustedLimit = max(10, min(limit, 100)) // 최소값 10, 최대값 100 적용
            var parameters: [String: Any] = ["limit": adjustedLimit]
            if let lastId = lastId {
                parameters["lastId"] = lastId - 1
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .uploadImage(_, let imageData):
            return .requestData(imageData)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .checkRegisteredUser:
            return ["Content-Type": "application/x-www-form-urlencoded"]
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
    
    var validationType: ValidationType { .successCodes }
}

enum Client: String {
    case kakao = "kakao"
    case apple = "apple"
}
