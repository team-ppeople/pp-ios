//
//  AuthEndpoint.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Moya

enum AuthAPI {
	case getToken(parameter: TokenRequest)
	case revokeToken(clientId: String, token: String, tokenTypeHint: String)
}

extension AuthAPI : TargetType {
	var baseURL: URL { URL(string: Url.server.rawValue)! }
	
	var path: String {
		switch self {
		case .getToken:
			return "/oauth2/token"
		case .revokeToken:
			return "/oauth2/revoke"
		}
	}
	
	var method: Moya.Method {
		switch self {
		case .getToken, .revokeToken:
			return .post
		}
	}
	
	var sampleData: Data {
		return .init()
	}
	
	var task: Task {
		switch self {
		case let .getToken(parameter):
			return .requestParameters(parameters: ["grant_type": parameter.grantType ?? "", "client_id": parameter.clientId ?? "", "client_assertion": parameter.clientAssertion ?? "", "client_assertion_type": parameter.clientAssertionType, "authorization_code": parameter.authorizationCode ?? "", "refresh_token": parameter.refreshToken ?? "", "scope": parameter.scope], encoding: URLEncoding.httpBody)
		case let .revokeToken(clientId, token, tokenTypeHint):
			return .requestParameters(parameters: ["client_id": clientId, "token": token, "token_type_hint": tokenTypeHint], encoding: JSONEncoding.default)
		}
	}
	
	var headers: [String : String]? {
		switch self {
		case .getToken, .revokeToken:
			return [
				"Content-Type": "application/x-www-form-urlencoded"
			]
		}
	}
	
	var validationType: ValidationType { .successCodes }
}
