//
//  LoginView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI
import KakaoSDKUser

struct LoginView: View {
	@State var isLinkActive: Bool = false
	
    var body: some View {
		NavigationStack {
			Text("커뮤니티 둘러보기")
				.font(.system(size: 22, weight: .bold))
				.padding(.bottom, 8)
			
			Text("커뮤니티는 피피노트 회원들만 이용할 수 있어요!")
				.font(.system(size: 12, weight: .regular))
				.padding(.bottom, 50)
			
			Button {
				if (UserApi.isKakaoTalkLoginAvailable()) {
					// 카카오톡을 통해 로그인
					UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
						if let error = error {
							print("카카오톡 인증 에러 - \(error)")
						} else {
							print("카카오톡 인증 성공 - \(oauthToken?.accessToken ?? "")")
							
							// 유저 정보 가져오기
							DispatchQueue.global().async {
								UserApi.shared.me { User, Error in
									if let nickname = User?.kakaoAccount?.profile?.nickname {
										print("닉네임 - \(nickname)")
									}
									if let email = User?.kakaoAccount?.email {
										print("이메일 - \(email)")
									}
								}
							}
						}
					}
				} else {
					// 카카오 계정으로 로그인
					UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
						if let error = error {
							print("카카오계정 인증 에러 - \(error)")
						} else {
							print("카카오계정 인증 성공 - \(oauthToken?.accessToken ?? "")")
							
							DispatchQueue.global().async {
								UserApi.shared.me { User, Error in
									if let nickname = User?.kakaoAccount?.profile?.nickname {
										print("닉네임 - \(nickname)")
									}
									if let email = User?.kakaoAccount?.email {
										print("이메일 - \(email)")
									}
								}
							}
						}
					}
				}
			} label: {
				HStack {
					Image("kakao.login.icon")
					Text("카카오로 시작하기")
						.tint(.black)
				}
				.frame(maxWidth: .infinity)
				.frame(height: 50)
				.navigationDestination(isPresented: $isLinkActive) {
					TermsAgreementView()
				}
			}
			.background(.kakao)
			.cornerRadius(10)
			.padding(.bottom, 10)
            .padding(.horizontal, 16)
		
			Button {
				print("TermsAgreementView로 이동 - A")
			} label: {
				NavigationLink(destination: TermsAgreementView()) {
					HStack {
						Image("apple.login.icon")
						Text("애플로 시작하기")
							.tint(.white)
					}
					.frame(maxWidth: .infinity)
					.frame(height: 50)
				}
			}
			.background(.black)
			.cornerRadius(10)
			.padding(.bottom, 10)
            .padding(.horizontal, 16)
		}
	}
}

#Preview {
	LoginView()
}
