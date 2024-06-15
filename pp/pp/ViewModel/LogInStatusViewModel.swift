//
//  SettingViewModel.swift
//  pp
//
//  Created by 김지현 on 2024/05/27.
//

import Combine

class LogInStatusViewModel: ObservableObject {
	private let authService = AuthService.shared

	private var cancellables = Set<AnyCancellable>()
	
	@Published var isLoggedIn: Bool = false
	@Published var isLoggedOut: Bool = false
	
	// MARK: - 로그인 감지
	func subscribeLogInSubject() {
		authService.logInSubject
			.sink { [weak self] receivedValue in
				if receivedValue {
					print("LogInStatusViewModel 로그인 감지!")
				}
				
				self?.isLoggedIn = receivedValue
			}
			.store(in: &cancellables)
	}
	
	// MARK: - 로그아웃 감지
	func subscribeLogOutSubject() {
		authService.logOutSubject
			.sink { [weak self] receivedValue in
				if receivedValue {
					print("LogInStatusViewModel 로그아웃 감지!")
				}
				
				self?.isLoggedOut = receivedValue
			}
			.store(in: &cancellables)
	}
}
