//
//  UserEndpoint.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Moya

enum UserAPI {
    case checkRegisteredUser(client: Client, idToken: String)
}

extension UserAPI : TargetType {
    var baseURL: URL { URL(string: BaseUrl.server.rawValue)! }
    
    var path: String {
        switch self {
        case let .checkRegisteredUser(client, _):
            return "/api/v1/oauth2/\(client)/users/registered"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .checkRegisteredUser:
            return .post
        }
    }
    
    var sampleData: Data {
        return .init()
    }
    
    var task: Task {
        switch self {
        case let .checkRegisteredUser(_, idToken):
            return .requestParameters(parameters: ["idToken": idToken], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .checkRegisteredUser:
            return [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
        }
    }
    
    var validationType: ValidationType { .successCodes }
}

enum Client: String {
    case kakao = "kakao"
    case apple = "apple"
}
