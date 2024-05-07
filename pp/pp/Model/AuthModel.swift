//
//  AuthModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation

//MARK: - 토큰 발급 요청 구조체
struct TokenRequest {
	var grantType: String?
	var clientId: String?
	var clientAssertion: String?
	var clientAssertionType: String = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
	var authorizationCode: String?
	var refreshToken: String?
	var scope: String = "user.read user.write post.read post.write file.write"
}

//MARK: - 토큰 발급 응답 구조체
struct TokenResponse: Codable {
	var accessToken: String
	var refreshToken: String
	var expiresIn: Int
	
	enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case refreshToken = "refresh_token"
		case expiresIn = "expires_in"
	}
}
