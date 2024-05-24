//
//  SettingView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject var vm: CommunityViewModel = CommunityViewModel()
    
    @State var isLoggedIn: Bool = false
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
					if isLoggedIn {
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
					
					if isLoggedIn {
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
                    
                    Button("Show Modal") {
                                  showModal.toggle()
                              }
                              .sheet(isPresented: $showModal) {
                                  EditProfileView(vm: vm)
                                      .presentationDetents([.fraction(5/12)]) // 화면의 1/3 높이로 설정
                                      .presentationDragIndicator(.visible) // 드래그 인디케이터를 표시
                                      .cornerRadius(40)
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



//#Preview {
//	SettingView(isLoggedIn: false)
//}
