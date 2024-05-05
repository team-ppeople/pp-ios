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
    private let authProvider = MoyaProvider<AuthAPI>()
    private let userProvider = MoyaProvider<UserAPI>()
    private var subscription = Set<AnyCancellable>()
    
	@Published var isLinkActive: Bool = false
    @Published var showAlert: Bool = false
	
	private var clientId: String = ""
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
                    self?.requestKakaoUserProfile()
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
					self?.requestKakaoUserProfile()
				}
			}
		}
	}
	
	// MARK: - kakao 유저 정보
    func requestKakaoUserProfile() {
		UserApi.shared.me { [weak self] User, Error in
			let email = User?.kakaoAccount?.email ?? ""
			print("이메일 - \(email)")
			self?.clientId = email
            self?.checkRegisteredUser(client: .kakao)
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
					print("Apple Login Successful")
					switch authResults.credential {
					case let appleIDCredential as ASAuthorizationAppleIDCredential:
						let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8) ?? ""
						let authorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8) ?? ""
						let email = appleIDCredential.email ?? ""
						
						self?.clientId = email
						
						print("애플 인증 성공 - id_token: \(identityToken), auth_code: \(authorizationCode)")
						
						self?.authCode = authorizationCode
						self?.idToken = identityToken
						
                        self?.checkRegisteredUser(client: .apple)
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
    func checkRegisteredUser(client: Client) {
		// MARK: - 회원여부 체크 API 요청
		userProvider.requestPublisher(.checkRegisteredUser(client: client, idToken: self.idToken))
            .sink { [weak self] completion in
                print(completion)
                switch completion {
                case let .failure(error):
                    print("회원 등록 여부 확인 Fail - \(error.localizedDescription)")
					self?.showAlert = true
                case .finished:
                    print("회원 등록 여부 확인 Finished")
                }
            } receiveValue: { [weak self] recievedValue in
				guard let responseData = try? recievedValue.map(CheckRegisteredUserResponse.self) else {
					self?.showAlert = true
					return
				}
                
                print("회원 등록 여부 확인 Success")
                print(JSON(recievedValue.data))
				
				guard let isRegistered = responseData.data.isRegistered else {
					self?.showAlert = true
					return
				}
				
				if isRegistered {
					self?.login()
				} else {
					self?.isLinkActive = true
					self?.destination = .termsAgreement
				}
            }.store(in : &subscription)
    }
    
	// MARK: - 로그인
	func login() {
		let tokenRequest = TokenRequest(grantType: "client_credentials", clientId: self.clientId, clientAssertion: self.idToken, authorizationCode: self.authCode)
		
		// MARK: - 피피 토큰 발급 API 요청
		authProvider.requestPublisher(.getToken(parameter: tokenRequest))
			.sink { [weak self] completion in
				print(completion)
				switch completion {
				case let .failure(error):
					print("피피 토큰 발급 Fail - \(error.localizedDescription)")
					self?.showAlert = true
				case .finished:
					print("피피 토큰 발급 Finished")
				}
			} receiveValue: { [weak self] recievedValue in
				guard let responseData = try? recievedValue.map(TokenResponse.self) else {
					self?.showAlert = true
					return
				}
				
				print("피피 토큰 발급 Success")
				print(JSON(recievedValue.data))
				
				let accessToken = responseData.accessToken
				let refreshToken = responseData.refreshToken
				
				UserDefaults.standard.set(accessToken, forKey: "AccessToken")
				UserDefaults.standard.set(refreshToken, forKey: "RefreshToken")
				
				self?.isLinkActive = true
				self?.destination = .community
			}.store(in : &subscription)
	}
}

enum Destination {
	case community
	case termsAgreement
}
