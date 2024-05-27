//
//  ContentViewModel.swift
//  pp
//
//  Created by 김지현 on 2024/05/27.
//

import Moya
import Combine
import SwiftyJSON

class AppViewModel: ObservableObject {
	private let authService = AuthService.shared
	private var cancellables = Set<AnyCancellable>()
	
	private let accessToken = UserDefaults.standard.string(forKey: "AccessToken")
	private let refreshToken = UserDefaults.standard.string(forKey: "RefreshToken")
	private let clientId = UserDefaults.standard.string(forKey: "ClientId")
	
	// MARK: - 로그인 여부 체크
	func checkLogin() -> Bool {
		if let accessToken = accessToken, accessToken != "" {
			authService.accessTokenSubject.send(accessToken)
			return true
		} else {
			return false
		}
	}
	
	// MARK: - jwt 토큰 체크
	func checkAccessToken() {
		guard let accessToken = accessToken else { return }
		guard let issuedAt = Utils.decode(accessToken)["iat"] as? Int else { return }
		guard let expiration = Utils.decode(accessToken)["exp"] as? Int else { return }
		
		print("iss - \(issuedAt), exp - \(expiration)")
		
		if expiration - issuedAt < 2 {
			let tokenRequest: TokenRequest = TokenRequest(grantType: "refresh_token", clientId: clientId, refreshToken: refreshToken)
			authService.fetchRefreshToken(tokenRequest: tokenRequest)
		}
	}
}
