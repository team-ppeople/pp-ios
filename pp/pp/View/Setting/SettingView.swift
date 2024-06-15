//
//  SettingView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI
import Combine

struct SettingView: View {

	@ObservedObject var vm: LogInStatusViewModel = LogInStatusViewModel()
    @ObservedObject var userVm: UserViewModel = UserViewModel()
	
	@State var isLoggedIn: Bool

	@State var showNoticeAlert: Bool = false
    @State private var showModal = false
//	
//	init(isLoggedIn: Bool) {
//		self.isLoggedIn = isLoggedIn
//	}
//	
    var body: some View {

		NavigationStack {
			GeometryReader { geometry in
				VStack {
					// MARK: - isLoggedIn: 앱 시작시 로그인 된 상태, vm.isLoggedIn: 로그인API 요청 후 로그인 된 상태, vm.isLoggedOut: 로그아웃 한 상태 (로그아웃API 요청, 또는 토큰 갱신 실패시)
					if (isLoggedIn || vm.isLoggedIn) && !vm.isLoggedOut {
                        NavigationLink(destination: UserProfileView(vm: userVm, userId: nil)) {
                            MyProfileView(vm: userVm)
                        }
					}
					
//					Button (action: {
//						showNoticeAlert = true
//					}, label: {
//						createBoxStyle("공지사항")
//							.alert(isPresented: $showNoticeAlert) {
//								return Alert(title: Text(""), message: Text("아직 공지사항이 없습니다."))
//							}
//					})
//					.padding(.bottom, 12)
                    NavigationLink(destination: NoticeView(vm: userVm)) {
                                            createBoxStyle("공지사항")
                                        }
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
					
					if (isLoggedIn || vm.isLoggedIn) && !vm.isLoggedOut {
						Button (action: {
							userVm.logout()
						}, label: {
							createBoxStyle("로그아웃", isOnlyText: true)
						})
						.padding(.bottom, 12)
						
						Button (action: {
							userVm.deleteUser()
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
		} .task {
            if let userIdString = UserDefaults.standard.string(forKey: "UserId"), let userId = Int(userIdString) {
                userVm.fetchUserProfile(userId: userId)
            } else {
                print("No valid userId found in UserDefaults")
            }
        }
		.onAppear {
			vm.subscribeLogInSubject()
			vm.subscribeLogOutSubject()
		}

    }

    private func createBoxStyle(_ text: String, version: String = "", isOnlyText: Bool = false) -> some View {
        HStack {
            Text(text).tint(.black)
            Spacer()
            if version.isEmpty {
                Image(systemName: "chevron.right")
                    .tint(.black)
            } else if isOnlyText {
                Image(systemName: "chevron.right")
                    .hidden()
                Text(version).hidden()
            } else {
                Image(systemName: "chevron.right")
                    .hidden()
                Text(version).tint(.accent)
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


