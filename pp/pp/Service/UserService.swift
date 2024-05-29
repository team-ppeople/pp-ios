//
//  UserService.swift
//  pp
//
//  Created by 김지현 on 2024/05/07.
//

import Moya
import Combine

class UserService {

	static let shared = UserService()
	
	private var cancellables = Set<AnyCancellable>()
	
	lazy var provider = MoyaProvider<UserAPI>(plugins: [networkLogger])
	lazy var networkLogger = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
	
	// MARK: - 등록된 피피 회원 유저인지 여부 체크
	func checkRegisteredUser(client: Client, idToken: String) -> AnyPublisher<CheckRegisteredUserResponse, APIError> {
		return provider
			.requestPublisher(.checkRegisteredUser(client: client, idToken: idToken))
			.tryMap { response -> CheckRegisteredUserResponse in
				return try JSONDecoder().decode(CheckRegisteredUserResponse.self, from: response.data)
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	//MARK: - 유저 정보 수정
	func editUserInfo(userId: Int, profile: EditProfileRequest) -> AnyPublisher<Void, APIError> {
		provider.requestPublisher(.editUserInfo(userId: userId, profile: profile))
			.map { _ in Void() }
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	//MARK: - 유저 탈퇴
	func deleteUser(userId:Int) -> AnyPublisher<Void,APIError> {
		provider.requestPublisher(.deleteUser(userId: userId))
			.map { _ in Void() }
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	//MARK: - 유저 프로필 조회
	func fetchUserProfile(userId: Int) -> AnyPublisher<UserProfileResponse, APIError> {
		provider.requestPublisher(.fetchUserProfile(userId: userId))
			.tryMap { response in
				return try JSONDecoder().decode(UserProfileResponse.self, from: response.data)
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	// MARK: - 유저 게시글 목록 조회
	func fetchUserPosts(userId: Int, limit: Int = 20, lastId: Int? = nil) -> AnyPublisher<UserPostsResponse, APIError> {
		provider.requestPublisher(.fetchUserPosts(userId: userId, limit: limit, lastId: lastId))
			.tryMap { response in
				return try JSONDecoder().decode(UserPostsResponse.self, from: response.data)
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
}
