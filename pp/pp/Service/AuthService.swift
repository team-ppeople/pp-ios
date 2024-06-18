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
	
	private var cancellables = Set<AnyCancellable>()
	
	lazy var provider = MoyaProvider<AuthAPI>(plugins: [networkLogger])
	lazy var networkLogger = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
	
	var accessTokenSubject = PassthroughSubject<String, Never>()
	var logInSubject = CurrentValueSubject<Bool, Never>(false)
	var logOutSubject = CurrentValueSubject<Bool, Never>(false)
	
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
	
	// MARK: - 토큰 재발급 (401인 경우)
	func refreshToken() -> AnyPublisher<TokenResponse, APIError> {
		var parameter: TokenRequest = TokenRequest()
		parameter.grantType = "refresh_token"
		parameter.refreshToken = UserDefaults.standard.string(forKey: "RefreshToken")
		parameter.clientId = UserDefaults.standard.string(forKey: "ClientId")
		
		return provider
			.requestPublisher(.getToken(parameter: parameter))
			.tryMap { response -> TokenResponse in
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
	// MARK: - 토큰 재발급 구현부
	func fetchRefreshToken(competionHandler: @escaping () -> Void) {
		self.refreshToken()
			.sink(receiveCompletion: { completion in
				switch completion {
				case .finished:
					print("토큰 재발급 완료")
					competionHandler()
				case .failure(let error):
					print("토큰 재발급 Error")
					dump(error)
					
					self.logInSubject.send(false)
					self.logOutSubject.send(true)
					
					UserDefaults.standard.set(nil, forKey: "AccessToken")
					UserDefaults.standard.set(nil, forKey: "RefreshToken")
					UserDefaults.standard.set(nil, forKey: "UserId")
					UserDefaults.standard.set(nil, forKey: "ClientId")
				}
			}, receiveValue: { [weak self] receivedValue in
				dump(receivedValue)
				
				let accessToken = receivedValue.accessToken
				let refreshToken = receivedValue.refreshToken
				
				self?.accessTokenSubject.send(accessToken)
				
				UserDefaults.standard.set(accessToken, forKey: "AccessToken")
				UserDefaults.standard.set(refreshToken, forKey: "RefreshToken")
			})
			.store(in: &cancellables)
	}
}
