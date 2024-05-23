//
//  AuthService.swift
//  pp
//
//  Created by 김지현 on 2024/05/07.
//

import Moya
import Combine

//MARK: - Auth API 통신
class AuthService {
	static let shared = AuthService()
	private let provider = MoyaProvider<AuthAPI>()
	
	var accessTokenSubject = PassthroughSubject<String, Never>()
	
	private init() {}
	
	//MARK: - 토큰 발급 (로그인)
	func getToken(tokenRequest: TokenRequest) -> AnyPublisher<TokenResponse, APIError> {
		var parameter = tokenRequest
		parameter.grantType = "client_credentials"
		
		return provider
			.requestPublisher(.getToken(parameter: parameter))
			.tryMap { response -> TokenResponse in
				
				return try JSONDecoder().decode(TokenResponse.self, from: response.data)
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	// MARK: - 토큰 재발급 (400 Bad Reqeust인 경우 리프레시)
	func refreshToken(tokenRequest: TokenRequest) -> AnyPublisher<TokenResponse, APIError> {
		var parameter = tokenRequest
		parameter.grantType = "refresh_token"
		
		return provider
			.requestPublisher(.getToken(parameter: parameter))
			.tryMap { response -> TokenResponse in
				guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
					let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
					throw apiError
				}
				return try JSONDecoder().decode(TokenResponse.self, from: response.data)
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	// MARK: - 토큰 삭제 (애플의 경우)
	func revokeToken() {
		
	}
}


extension AuthService {
	
}
