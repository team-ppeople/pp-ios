//
//  ppApp.swift
//  pp
//
//  Created by 김지현 on 2024/04/02.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct ppApp: App {
	init() {
		// Kakao SDK 초기화
		KakaoSDK.initSDK(appKey: Secrets().kakaoAppKey)
	}
	
    var body: some Scene {
        WindowGroup {
			// onOpenURL()을 사용해 커스텀 URL 스킴 처리
			ContentView()
				.onOpenURL(perform: { url in
					if (AuthApi.isKakaoTalkLoginUrl(url)) {
						_ = AuthController.handleOpenUrl(url: url)
					}
				})
        }
    }
}
