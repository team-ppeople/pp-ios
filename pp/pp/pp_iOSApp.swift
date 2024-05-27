//
//  pp_iosApp.swift
//  pp
//
//  Created by 김지현 on 2024/05/27.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct pp_iOSApp: App {
	@ObservedObject var vm: AppViewModel = AppViewModel()
	
	private var isLoggedIn: Bool = false
	
	// MARK: - didFinishLaunchingWithOption의 로직
	init () {
		KakaoSDK.initSDK(appKey: Secrets().kakaoAppKey)
		
		self.vm.checkAccessToken()
		self.isLoggedIn = self.vm.checkLogin()
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView(isLoggedIn: isLoggedIn)
				.onOpenURL(perform: { url in
					if (AuthApi.isKakaoTalkLoginUrl(url)) {
						_ = AuthController.handleOpenUrl(url: url)
					}
				})
		}
	}
}
