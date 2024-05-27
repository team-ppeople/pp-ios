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
	
	// MARK: - 로그인 감지
	func subscribeLogInSubject() {
		authService.logInSubject
			.sink { _ in
				self.isLoggedIn = true
			}
			.store(in: &cancellables)
	}
}
