//
//  UserModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation

//MARK: - 회원 여부 체크 응답 구조체
struct CheckRegisteredUserResponse: Codable {
    var registered: Bool?
}
