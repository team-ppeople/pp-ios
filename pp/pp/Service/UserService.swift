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
    
    lazy var provider = MoyaProvider<CommunityAPI>(plugins: [networkLogger])
    lazy var networkLogger = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    
    private init() {}
    
    
    
    
    
    
}




extension UserService {
    func handleError<T>(_ error: Error, retry: @escaping () -> AnyPublisher<T, APIError>) -> AnyPublisher<T, APIError> {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                dump(response)
                if let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) {
                    if apiError.status == 400 {
                        // 토큰 갱신 시도
                        return refreshTokenIfNeeded()
                            .flatMap { _ in retry() }
                            .eraseToAnyPublisher()
                    } else {
                        // 다른 에러는 그대로 반환
                        return Fail(error: apiError).eraseToAnyPublisher()
                    }
                } else {
                    // 디코딩 실패 시 기본 에러 반환
                    return Fail(error: APIError(type: "about:blank", title: "Decoding Error", status: 500, detail: "Error decoding error response", instance: response.request?.url?.absoluteString ?? "")).eraseToAnyPublisher()
                }
            default:
                return Fail(error: APIError(type: "about:blank", title: "Moya Error", status: 500, detail: "A Moya error occurred.", instance: "/error")).eraseToAnyPublisher()
            }
        } else {
            print("Received non-Moya error: \(type(of: error)) - \(error.localizedDescription)")
            // MoyaError가 아닌 경우
            return Fail(error: APIError(type: "about:blank", title: "Non-Moya Error", status: 500, detail: error.localizedDescription, instance: "/error-non-moya")).eraseToAnyPublisher()
        }
    }

    //MARK: - 토큰 재발급 요청
    func refreshTokenIfNeeded() -> AnyPublisher<Void, APIError> {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            // 토큰이 존재하지 않을 때 처리
            return Fail(error: APIError(type: "about:blank", title: "Token Error", status: 401, detail: "No refresh token available.", instance: "/token-error")).eraseToAnyPublisher()
        }

        let tokenRequest = TokenRequest(refreshToken: refreshToken)
        return AuthService.shared.refreshToken(tokenRequest: tokenRequest)
            .map { tokenResponse -> Void in
                // 성공적으로 토큰을 갱신했을 때 필요한 처리
                UserDefaults.standard.set(tokenResponse.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(tokenResponse.refreshToken, forKey: "refreshToken")
                return Void()
            }
            .mapError { error -> APIError in
                // 토큰 갱신 실패 시 에러 처리
                return APIError(type: "about:blank", title: "Token Refresh Error", status: error.status, detail: "Failed to refresh token.", instance: "/token-refresh-fail")
            }
            .eraseToAnyPublisher()
    }
    
}
