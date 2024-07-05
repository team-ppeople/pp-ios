//
//  APIErrorModel.swift
//  pp
//
//  Created by 김지현 on 2024/05/07.
//

import Foundation

//MARK: - HTTP 통신 에러 Type
struct APIError: Error,Codable {
    let description: String?
	let statusCode: Int?
	let instance: String?
    var detail: String?
}
