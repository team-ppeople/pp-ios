//
//  LoginView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct LoginView: View {
	@ObservedObject var vm: LoginViewModel = LoginViewModel()

	
    var body: some View {
		NavigationStack {
			Text("커뮤니티 둘러보기")
				.font(.system(size: 22, weight: .bold))
				.padding(.bottom, 8)
			
			Text("커뮤니티는 피피노트 회원들만 이용할 수 있어요!")
				.font(.system(size: 12, weight: .regular))
				.padding(.bottom, 50)
			
			Button {
				vm.requestKakaoOauth()
			} label: {
				HStack {
					Image("kakao.login.icon")
					Text("카카오로 시작하기")
						.tint(.black)
				}
				.frame(maxWidth: .infinity)
				.frame(height: 50)
				.navigationDestination(isPresented: $vm.isKaKaoLinkActive) {
					switch vm.destination {
					case .community:
                        CommunityView()
					case .termsAgreement:
						TermsAgreementView(vm: vm)
					case .none:
						TermsAgreementView(vm: vm)
					}
				}
				.alert(isPresented: $vm.showAlert) {
					return Alert(title: Text(""), message: Text("로그인에 실패하였습니다."))
				}
			}
			.background(.kakao)
			.cornerRadius(10)
			.padding(.bottom, 10)
            .padding(.horizontal, 16)
		
			Button {} label: {
				HStack {
					Image("apple.login.icon")
					Text("애플로 시작하기")
						.tint(.white)
				}
				.frame(maxWidth: .infinity)
				.frame(height: 50)
				.navigationDestination(isPresented: $vm.isAppleLinkActive) {
					switch vm.destination {
					case .community:
                        CommunityView()
					case .termsAgreement:
						TermsAgreementView(vm: vm)
					case .none:
						TermsAgreementView(vm: vm)
					}
				}
				.alert(isPresented: $vm.showAlert) {
					return Alert(title: Text(""), message: Text("로그인에 실패하였습니다."))
				}
			}
			.background(.black)
			.cornerRadius(10)
			.padding(.bottom, 10)
			.padding(.horizontal, 16)
			.overlay {
				vm.requestAppleOauth()
					.frame(maxWidth: 375)
					.frame(height: 44)
					.blendMode(.overlay)
			}
		}
	}
}

#Preview {
	LoginView()
}
