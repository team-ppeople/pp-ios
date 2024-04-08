//
//  LoginView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
		NavigationStack {
			Text("커뮤니티 둘러보기")
				.font(.system(size: 22, weight: .bold))
				.padding(.bottom, 8)
			
			Text("커뮤니티는 피피노트 회원들만 이용할 수 있어요!")
				.font(.system(size: 12, weight: .regular))
				.padding(.bottom, 50)
			
			Button {
				print("TermsAgreementView로 이동 - K")
			} label: {
				NavigationLink(destination: TermsAgreementView()) {
					HStack {
						Image("kakao.login.icon")
						Text("카카오로 시작하기")
							.tint(.black)
					}
					.frame(maxWidth: .infinity)
					.frame(height: 50)
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
