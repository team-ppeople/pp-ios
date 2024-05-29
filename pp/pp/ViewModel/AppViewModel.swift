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
		let currentDate = Date().timeIntervalSince1970
		
		print("iss - \(issuedAt), exp - \(expiration), currentDate - \(currentDate)")
		
		if expiration - issuedAt < 2 {
			print("토큰 만료됨:: \(expiration - issuedAt)")
			self.authService.fetchRefreshToken()
		}
	}
}
