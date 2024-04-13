//
//  LoginViewModel.swift
//  pp
//
//  Created by 김지현 on 2024/04/10.
//

import Foundation
import KakaoSDKUser
import _AuthenticationServices_SwiftUI

class LoginViewModel: ObservableObject {
	@Published var isLinkActive: Bool = false
	@Published var showAlert: Bool = false
	@Published var accessToken: String = ""
	@Published var idToken: String = ""
	
	func requestKakaoOauth() {
		if (UserApi.isKakaoTalkLoginAvailable()) {
			// 카카오톡을 통해 로그인
			UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
				if let error = error {
					print("카카오톡 인증 에러 - \(error)")
					self?.showAlert = true
				} else {
					print("카카오톡 인증 성공 - \(oauthToken?.accessToken ?? "")")
					self?.accessToken = oauthToken?.accessToken ?? ""
				}
			}
		} else {
			// 카카오 계정으로 로그인
			UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
				if let error = error {
					print("카카오계정 인증 에러 - \(error)")
					self?.showAlert = true
				} else {
					print("카카오계정 인증 성공 - \(oauthToken?.accessToken ?? "")")
					self?.accessToken = oauthToken?.accessToken ?? ""
				}
			}
		}
	}
	
	func requestAppleOauth() -> SignInWithAppleButton {
		return SignInWithAppleButton(
			onRequest: { request in
				request.requestedScopes = [.fullName, .email]
			},
			onCompletion: { result in
				switch result {
				case .success(let authResults):
					print("Apple Login Successful")
					switch authResults.credential{
					case let appleIDCredential as ASAuthorizationAppleIDCredential:
						let IdentityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
						let AuthorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)
						print("애플 인증 성공 - id_token: \(IdentityToken ?? ""), auth_code: \(AuthorizationCode ?? "")")
					default:
						break
					}
				case .failure(let error):
					print(error.localizedDescription)
					print("애플 인증 에러 - \(error)")
				}
			}
		)
	}
	
	func requestPPOauth(_ diaryPost: DiaryPost) {
		// pp oauth api 요청
	}
}
