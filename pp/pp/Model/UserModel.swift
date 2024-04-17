//
//  UserModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation

struct CheckRegisteredUserResponse: Codable {
    var data: IsRegisteredUser?
}

struct IsRegisteredUser: Codable {
    var isRegistered: Bool?
}
