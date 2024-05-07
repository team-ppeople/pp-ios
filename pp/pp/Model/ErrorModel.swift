//
//  APIErrorModel.swift
//  pp
//
//  Created by 김지현 on 2024/05/07.
//

import Foundation


//MARK: - APIError Type

struct APIError: Decodable, Error {
    let type: String
    let title: String
    let status: Int
    let detail: String
    let instance: String
}
