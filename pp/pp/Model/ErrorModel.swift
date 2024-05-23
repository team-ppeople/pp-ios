//
//  APIErrorModel.swift
//  pp
//
//  Created by 김지현 on 2024/05/07.
//

import Foundation


//MARK: - HTTP 통신 에러 Type
struct APIError: Decodable, Error {
    let description: String?
	let statusCode: Int?
	
	// MARK: - PP 서버에서 주는 에러 응답
	let type: String?
	let title: String?
	let detail: String?
	let instance: String?
	let status: Int?
}
