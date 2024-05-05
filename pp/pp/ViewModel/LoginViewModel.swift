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
    private let provider = MoyaProvider<UserAPI>()
    private var subscription = Set<AnyCancellable>()
    
	@Published var isLinkActive: Bool = false
    @Published var showAlert: Bool = false
	@Published var authCode: String?
	
	func requestKakaoOauth() {
		if (UserApi.isKakaoTalkLoginAvailable()) {
			// 카카오톡을 통해 로그인
			UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
				if let error = error {
					print("카카오톡 인증 에러 - \(error)")
					self?.showAlert = true
				} else {
					print("카카오톡 인증 성공 - \(oauthToken?.accessToken ?? "")")
                    self?.requestKakaoUserProfile(accessToken: oauthToken?.accessToken)
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
					self?.requestKakaoUserProfile(accessToken: oauthToken?.accessToken)
				}
			}
		}
	}
	
    func requestKakaoUserProfile(accessToken: String?) {
		UserApi.shared.me { [weak self] User, Error in
			print("이메일 - \(User?.kakaoAccount?.email ?? "")")
            self?.checkRegisteredUser(client: .kakao, idToken: accessToken ?? "")
		}
	}
	
	func requestAppleOauth() -> SignInWithAppleButton {
		return SignInWithAppleButton(
			onRequest: { request in
				request.requestedScopes = [.fullName, .email]
			},
			onCompletion: { [weak self] result in
				switch result {
				case .success(let authResults):
					print("Apple Login Successful")
					switch authResults.credential{
					case let appleIDCredential as ASAuthorizationAppleIDCredential:
						let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
						let authorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)
						let email = appleIDCredential.email
						
						print("애플 인증 성공 - id_token: \(identityToken ?? ""), auth_code: \(authorizationCode ?? "")")
						
						self?.authCode = authorizationCode
                        self?.checkRegisteredUser(client: .apple, idToken: identityToken ?? "")
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
    
    func checkRegisteredUser(client: Client, idToken: String) {
        provider.requestPublisher(.checkRegisteredUser(client: client, idToken: idToken))
            .sink { completion in
                print(completion)
                switch completion {
                case let .failure(error) :
                    print("회원 등록 여부 확인 Fail - \(error.localizedDescription)")
                case .finished :
                    print("회원 등록 여부 확인 Finished")
                }
            } receiveValue: { [weak self] recievedValue in
				guard let responseData = try? recievedValue.map(CheckRegisteredUserResponse.self) else {
					self?.showAlert = true
					return
				}
                
                print("회원 등록 여부 확인 Success")
                print(JSON(recievedValue.data))
				
				guard let isRegistered = responseData.registered else {
					self?.showAlert = true
					return
				}
				
				if isRegistered {
					self?.login()
				} else {
					self?.isLinkActive = true
				}
            }.store(in : &subscription)
    }
    
    func login() {
		// pp oauth api 요청
	}
}
