//
//  ContentView.swift
//  pp
//
//  Created by 김지현 on 2024/04/02.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var isLoggedIn: Bool = false
	
	init() {
		let appearance: UITabBarAppearance = UITabBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.shadowColor = UIColor.darkSubColor
		UITabBar.appearance().standardAppearance = appearance
		UITabBar.appearance().scrollEdgeAppearance = appearance
	}
    
    var body: some View {
        TabView {
            DiaryView()
                .tabItem {
                    VStack {
                        Image(systemName: "folder.badge.person.crop")
                        Text("나의 일기")
                    }
                }
            if isLoggedIn {
                CommunityView()
                    .tabItem {
                        VStack {
                            Image(systemName: "person.3.fill")
                            Text("커뮤니티")
                        }
                    }
            } else {
                LoginView()
                    .tabItem {
                        VStack {
                            Image(systemName: "person.3.fill")
                            Text("커뮤니티")
                        }
                    }
            }
            SettingView()
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("설정")
                    }
                }
		}
    }
}

#Preview {
    ContentView()
}
