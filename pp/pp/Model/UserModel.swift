//
//  UserModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation

//MARK: - 회원 여부 체크 응답 구조체
struct CheckRegisteredUserResponse: Codable {
	var data: Registered
}

struct Registered: Codable {
	var isRegistered: Bool?
}



//MARK: - 회원 정보 수정
struct EditProfileRequest : Codable {
    var nickname:String
    var profileImageFileUploadId:Int
}

//MARK: - 유저 프로필 조회
struct UserProfileResponse: Codable {
    let data: UserData
}

struct UserData: Codable {
    let user: UserProfile
}

struct UserProfile: Codable {
    let id: Int
    let nickname: String
    let profileImageUrl: String
    let postCount: Int
    let thumbsUpCount: Int
    let posts: [Post]
}
