//
//  SettingView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI
import Combine

struct SettingView: View {
	@ObservedObject var vm: SettingViewModel = SettingViewModel()
	
	@State var isLoggedIn: Bool
	@State var showNoticeAlert: Bool = false
	
	init(isLoggedIn: Bool) {
		self.isLoggedIn = isLoggedIn
	}
	
    var body: some View {
		NavigationStack {
			GeometryReader { geometry in
				VStack {
					// MARK: - isLoggedIn: 앱 시작시 로그인 된 상태, vm.isLoggedIn: 로그인API 요청 후 로그인 된 상태
					if isLoggedIn || vm.isLoggedIn {
						MyProfileView()
					}
					
					Button (action: {
						showNoticeAlert = true
					}, label: {
						createBoxStyle("공지사항")
							.alert(isPresented: $showNoticeAlert) {
								return Alert(title: Text(""), message: Text("아직 공지사항이 없습니다."))
							}
					})
					.padding(.bottom, 12)
					
					Button (action: {
						print("")
					}, label: {
						Link(destination: URL(string: Url.privacyPolicy.rawValue)!) {
							createBoxStyle("개인정보 처리 방침")
						}
					})
					.padding(.bottom, 12)
					
					Button (action: {
						print("")
					}, label: {
						Link(destination: URL(string: Url.termsAndCondition.rawValue)!) {
							createBoxStyle("서비스 이용 약관")
						}
					})
					.padding(.bottom, 12)
					
					createBoxStyle("버전 정보", version: currentAppVersion())
						.padding(.bottom, 12)
					
					if isLoggedIn || vm.isLoggedIn {
						Button (action: {
							print("")
						}, label: {
							createBoxStyle("로그아웃", isOnlyText: true)
						})
						.padding(.bottom, 12)
						
						Button (action: {
							print("")
						}, label: {
							createBoxStyle("탈퇴하기", isOnlyText: true)
						})
						.padding(.bottom, 12)
					}
					
					Spacer()
				}
				.padding(.top, 24)
				.padding(.horizontal, 16)
				.toolbar {
					ToolbarItem {
						HStack {
							Text("설정")
								.font(.system(size: 20))
								.bold()
								.padding(.leading, 16)
							Spacer()
						}
						.frame(width: geometry.size.width, height: 45)
						.background(.white)
					}
				}
			}
		}
		.onAppear {
			vm.subscribeLogInSubject()
		}
    }
	
	private func createBoxStyle(_ text: String, version: String = "", isOnlyText: Bool = false) -> some View {
		HStack {
			Text(text)
				.tint(.black)
			Spacer()
			if version == "" {
				Text(text)
					.hidden()
				Image(systemName: "chevron.right")
					.tint(.black)
			} else if isOnlyText {
				Image(systemName: "chevron.right")
					.hidden()
				Text(version)
					.hidden()
			} else {
				Image(systemName: "chevron.right")
					.hidden()
				Text(version)
					.tint(.accent)
			}
		}
		.frame(maxWidth: .infinity)
		.frame(height: 40)
		.padding(.horizontal, 15)
		.overlay(
			RoundedRectangle(cornerRadius: 5)
				.stroke(.sub, lineWidth: 1)
		)
	}
	
	private func currentAppVersion() -> String {
		let info: [String: Any]? = Bundle.main.infoDictionary
		let currentVersion: String? = info?["CFBundleShortVersionString"] as? String
		let buildNumber: String? = info?["CFBundleVersion"] as? String
		
		return "\(currentVersion ?? "1.0") (\(buildNumber ?? ""))"
	}
}

struct MyProfileView: View {
	var body: some View {
		HStack {
			Image("kakao.login.icon")
			Text("Hello, World!")
			Button (action: {
				print("")
			}, label: {
				Text("프로필 보기")
			})
		}
		
	}
}

#Preview {
	SettingView(isLoggedIn: false)
}
