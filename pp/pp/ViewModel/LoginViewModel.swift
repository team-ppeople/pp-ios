//
//  LoginViewModel.swift
//  pp
//
//  Created by 김지현 on 2024/04/10.
//

import Moya
import Combine
import KakaoSDKUser
import _AuthenticationServices_SwiftUI
import SwiftyJSON

class LoginViewModel: ObservableObject {
	private let authService = AuthService.shared
	private let userService = UserService.shared
	
    private var cancellables = Set<AnyCancellable>()
    
	@Published var isTermsLinkActive: Bool = false
    @Published var isAppleLinkActive: Bool = false
    @Published var isKaKaoLinkActive: Bool = false
    @Published var showAlert: Bool = false

	private var client: Client = .kakao
	private var authCode: String = ""
	private var idToken: String = ""
	var destination: Destination?
	
	// MARK: - kakao oauth
	func requestKakaoOauth() {
		if (UserApi.isKakaoTalkLoginAvailable()) {
			// 카카오톡을 통해 로그인
			UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
				if let error = error {
					print("카카오톡 인증 에러 - \(error)")
					self?.showAlert = true
				} else {
					print("카카오톡 인증 성공 - \(oauthToken?.idToken ?? "")")
					self?.idToken = oauthToken?.idToken ?? ""
					self?.client = .kakao
					self?.checkRegisteredUser()
				}
			}
		} else {
			// 카카오 계정으로 로그인
			UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
				if let error = error {
					print("카카오계정 인증 에러 - \(error)")
					self?.showAlert = true
				} else {
					print("카카오계정 인증 성공 - \(oauthToken?.idToken ?? "")")
					self?.idToken = oauthToken?.idToken ?? ""
					self?.client = .kakao
					self?.checkRegisteredUser()
				}
			}
		}
	}
	
	// MARK: - apple oauth
	func requestAppleOauth() -> SignInWithAppleButton {
		return SignInWithAppleButton(
			onRequest: { request in
				request.requestedScopes = [.fullName, .email]
			},
			onCompletion: { [weak self] result in
				switch result {
				case .success(let authResults):
					switch authResults.credential {
					case let appleIDCredential as ASAuthorizationAppleIDCredential:
						let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8) ?? ""
						let authorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8) ?? ""
						
						print("애플 인증 성공 - id_token: \(identityToken), auth_code: \(authorizationCode)")
                    
						self?.authCode = authorizationCode
						self?.idToken = identityToken
						self?.client = .apple
						
                        self?.checkRegisteredUser()
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
    
	// MARK: - 회원여부 체크
    func checkRegisteredUser() {
		// MARK: - 회원여부 체크 API 요청
		userService
			.checkRegisteredUser(client: self.client, idToken: self.idToken)
			.sink { [weak self] completion in
				switch completion {
				case .finished:
					print("회원 등록 여부 확인 Finished")
				case .failure(let error):
					print("회원 등록 여부 확인 Error")
					dump(error)
					
					self?.showAlert = true
				}
			} receiveValue: { [weak self] recievedValue in
				guard let isRegistered = recievedValue.data.isRegistered else {
					self?.showAlert = true
					return
				}
				
				if isRegistered {
					self?.login()
				} else {
					switch self?.client {
					case .kakao:
						self?.isKaKaoLinkActive = true
					case .apple:
						self?.isAppleLinkActive = true
					case .none:
						break
					}
				}
			}
			.store(in: &cancellables)
    }
    
	// MARK: - 로그인
	func login() {
		var tokenRequest: TokenRequest = TokenRequest(clientAssertion: self.idToken, clientAssertionType: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer", authorizationCode: self.authCode)
		
		switch self.client {
		case .kakao:
			tokenRequest.clientId = "kauth.kakao.com"
		case .apple:
			tokenRequest.clientId = "appleid.apple.com"
		}
		
		// MARK: - 피피 토큰 발급 API 요청
		authService
			.getToken(tokenRequest: tokenRequest)
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("토큰 발급 완료")
				case .failure(let error):
					print("토큰 발급 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken {
							print("fetchRefreshToken")
						}
					} else {
						self?.showAlert = true
					}
				}
			}, receiveValue: { [weak self] recievedValue in
				dump(recievedValue)
				
				let accessToken = recievedValue.accessToken
				let refreshToken = recievedValue.refreshToken
				
				self?.authService.accessTokenSubject.send(accessToken)
				
				UserDefaults.standard.set(accessToken, forKey: "AccessToken")
				UserDefaults.standard.set(refreshToken, forKey: "RefreshToken")
				
				let userId = Utils.decode(accessToken)["sub"] as? String ?? ""
				print("유저 아이디 - \(userId)")
				UserDefaults.standard.set(userId, forKey: "UserId")
				
				switch self?.client {
				case .kakao:
					self?.isKaKaoLinkActive = true
					UserDefaults.standard.set("kauth.kakao.com", forKey: "ClientId")
				case .apple:
					self?.isAppleLinkActive = true
					UserDefaults.standard.set("appleid.apple.com", forKey: "ClientId")
				case .none:
					break
				}
				self?.isTermsLinkActive = true
				self?.destination = .community
				
				self?.authService.logInSubject.send(true)
				self?.authService.logOutSubject.send(false)
			})
			.store(in: &cancellables)
	}
}

enum Destination {
	case community
	case termsAgreement
}
