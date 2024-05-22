//
//  SettingView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct SettingView: View {
	@State var isLoggedIn: Bool = false
	
	init(isLoggedIn: Bool) {
		self.isLoggedIn = isLoggedIn
	}
	
    var body: some View {
		if isLoggedIn {
			MyProfileView()
		}
		
		Button (action: {
			print("")
		}, label: {
			Text("공지사항")
		})
		
		Button (action: {
			print("")
		}, label: {
			Text("약관 및 정책")
		})
		
		Button (action: {
			print("")
		}, label: {
			Text("공지사항")
		})
		
		Button (action: {
			print("")
		}, label: {
			Text("공지사항")
		})
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
