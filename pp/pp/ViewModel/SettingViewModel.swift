//
//  SettingViewModel.swift
//  pp
//
//  Created by 김지현 on 2024/05/27.
//

import Combine

class SettingViewModel: ObservableObject {
	private let authService = AuthService.shared

	private var cancellables = Set<AnyCancellable>()
	
	@Published var isLoggedIn: Bool = false
	@Published var isLoggedOut: Bool = false
	
	// MARK: - 로그인 감지
	func subscribeLogInSubject() {
		authService.logInSubject
			.sink { _ in
				print("SettingViewModel 로그인 감지!")
				self.isLoggedIn = true
			}
			.store(in: &cancellables)
	}
	
	// MARK: - 로그아웃 감지
	func subscribeLogOutSubject() {
		authService.logOutSubject
			.sink { receivedValue in
				print(receivedValue)
				print("SettingViewModel 로그아웃 감지!")
				self.isLoggedOut = true
			}
			.store(in: &cancellables)
	}
}
