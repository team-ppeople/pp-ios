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
//	func checkRegisteredUser(client: Client, idToken: String) -> AnyPublisher<TokenResponse, APIError> {
//		provider
//			.requestPublisher(.checkRegisteredUser(client: client, idToken: idToken))
//			.tryMap { response -> TokenResponse in
//				guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
//					let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
//					throw apiError
//				}
//				return try JSONDecoder().decode(TokenResponse.self, from: response.data)
//			}
//			.catch { error in self.handleError(error, retry: { self.checkRegisteredUser(client: client, idToken: idToken) }) }
//			.eraseToAnyPublisher()
//	}
//	
//	//MARK: - 유저 정보 수정
//	func editUserInfo(userId: Int, profile: EditProfileRequest) -> AnyPublisher<Void, APIError> {
//		provider.requestPublisher(.editUserInfo(userId: userId, profile: profile))
//			.map { _ in Void() }
//			.catch { error in self.handleError(error, retry: { self.editUserInfo(userId: userId, profile: profile) }) }
//			.eraseToAnyPublisher()
//	}
//	
//	//MARK: - 유저 탈퇴
//	func deleteUser(userId:Int) -> AnyPublisher<Void,APIError> {
//		provider.requestPublisher(.deleteUser(userId: userId))
//			.map { _ in Void() }
//			.catch { error in self.handleError(error, retry: {self.deleteUser(userId: userId)}) }
//			.eraseToAnyPublisher()
//	}
//	
//	//MARK: - 유저 프로필 조회
//	func fetchUserProfile(userId: Int) -> AnyPublisher<UserProfileResponse, APIError> {
//		provider.requestPublisher(.fetchUserProfile(userId: userId))
//			.tryMap { response in
//				guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
//					throw APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "Invalid response", instance: response.request?.url?.absoluteString ?? "")
//				}
//				return try JSONDecoder().decode(UserProfileResponse.self, from: response.data)
//			}
//			.catch { error in self.handleError(error, retry: { self.fetchUserProfile(userId: userId) }) }
//			.eraseToAnyPublisher()
//	}
//	
//	// MARK: - 유저 게시글 목록 조회
//	func fetchUserPosts(userId: Int, limit: Int = 20, lastId: Int? = nil) -> AnyPublisher<UserPostsResponse, APIError> {
//		provider.requestPublisher(.fetchUserPosts(userId: userId, limit: limit, lastId: lastId))
//			.tryMap { response in
//				guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode < 300 else {
//					throw APIError(type: "about:blank", title: "Error", status: response.statusCode, detail: "Invalid response", instance: response.request?.url?.absoluteString ?? "")
//				}
//				return try JSONDecoder().decode(UserPostsResponse.self, from: response.data)
//			}
//			.catch { error in self.handleError(error, retry: { self.fetchUserPosts(userId: userId, limit: limit, lastId: lastId) }) }
//			.eraseToAnyPublisher()
//	}
	
}
