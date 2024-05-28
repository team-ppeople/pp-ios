//
//  CommunityTabView.swift
//  pp
//
//  Created by 김지현 on 2024/05/27.
//

import SwiftUI

struct CommunityTabView: View {
	@ObservedObject var vm: LogInStatusViewModel = LogInStatusViewModel()
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	@State var isLoggedIn: Bool
	
	var body: some View {
		NavigationStack {
			// MARK: - isLoggedIn: 앱 시작시 로그인 된 상태, vm.isLoggedIn: 로그인API 요청 후 로그인 된 상태, vm.isLoggedOut: 로그아웃 한 상태 (로그아웃API 요청, 또는 토큰 갱신 실패시)
			if (isLoggedIn || vm.isLoggedIn) && !vm.isLoggedOut {
				CommunityView()
					.onAppear {
						self.presentationMode.wrappedValue.dismiss()
					}
			} else {
				LoginView()
					.onAppear {
						self.presentationMode.wrappedValue.dismiss()
					}
			}
		}
		.onAppear {
			vm.subscribeLogInSubject()
			vm.subscribeLogOutSubject()
		}
	}
}




