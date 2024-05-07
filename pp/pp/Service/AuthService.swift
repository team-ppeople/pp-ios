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
	
	private init() {}
	
	//MARK: - 토큰 발급 (로그인)
	func getToken(tokenRequest: TokenRequest) -> AnyPublisher<TokenResponse, APIError> {
		var parameter = tokenRequest
		parameter.grantType = "client_credentials"
		
		return provider
			.requestPublisher(.getToken(parameter: parameter))
			.mapError (handleError)
			.tryMap { response -> TokenResponse in
				guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
					let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
					throw apiError
				}
				return try JSONDecoder().decode(TokenResponse.self, from: response.data)
			}
			.mapError(handleError)
			.eraseToAnyPublisher()
	}
	
	// MARK: - 토큰 재발급 (400 Bad Reqeust인 경우 리프레시)
	func refreshToken(tokenRequest: TokenRequest) -> AnyPublisher<TokenResponse, APIError> {
		var parameter = tokenRequest
		parameter.grantType = "refresh_token"
		
		return provider
			.requestPublisher(.getToken(parameter: parameter))
			.mapError (handleError)
			.tryMap { response -> TokenResponse in
				guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
					let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
					throw apiError
				}
				return try JSONDecoder().decode(TokenResponse.self, from: response.data)
			}
			.mapError(handleError)
			.eraseToAnyPublisher()
	}
	
	// MARK: - 토큰 삭제 (애플의 경우)
	func revokeToken() {
		
	}
}

//MARK: - Error 핸들링
extension AuthService {
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
