//
//  Utils.swift
//  pp
//
//  Created by 김지현 on 2024/04/05.
//

import Foundation
import UIKit
import SwiftUI
import Moya

class Utils {
	// MARK: - Data to Image
	static func createImage(_ value: Data?) -> Image {
		if let value = value {
			let uiImage: UIImage = UIImage(data: value) ?? UIImage(named: "emty.image")!
			return Image(uiImage: uiImage)
		} else {
			return Image("empty.image")
		}
	}
	
	// MARK: - date to string
	static func toString(_ date: Date?) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.string(from: date ?? Date())
	}

	// MARK: - decode JWT
	static func decode(_ jwt: String) -> [String: Any] {
		let segments = jwt.components(separatedBy: ".")
		return decodeJWTPart(segments[1]) ?? [:]
	}
	
	static func base64UrlDecode(_ value: String) -> Data? {
		var base64 = value
			.replacingOccurrences(of: "-", with: "+")
			.replacingOccurrences(of: "_", with: "/")
		
		let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
		let requiredLength = 4 * ceil(length / 4.0)
		let paddingLength = requiredLength - length
		if paddingLength > 0 {
			let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
			base64 = base64 + padding
		}
		return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
	}
	
	static func decodeJWTPart(_ value: String) -> [String: Any]? {
		guard let bodyData = base64UrlDecode(value),
			  let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
			return nil
		}
		
		return payload
	}
	
	//MARK: - Error 핸들링
	static func handleError(_ error: Error) -> APIError {
		if let moyaError = error as? MoyaError {
			switch moyaError {
			case .statusCode(let response):
				
				guard let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) else {
					return APIError(description: "MoyaError >> statusCode", statusCode: response.statusCode, type: nil, title: nil, detail: nil, instance: response.request?.url?.absoluteString, status: nil)
				}
				
				return APIError(description: "MoyaError >> statusCode >> Server Error Response", statusCode: response.statusCode, type: apiError.type, title: apiError.title, detail: apiError.detail, instance: apiError.instance, status: apiError.status)
				
			case .jsonMapping(let response):
				
				guard let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) else {
					return APIError(description: "MoyaError >> jsonMapping", statusCode: response.statusCode, type: nil, title: nil, detail: nil, instance: response.request?.url?.absoluteString, status: nil)
				}
				
				return APIError(description: "MoyaError >> jsonMapping >> Server Error Response", statusCode: response.statusCode, type: apiError.type, title: apiError.title, detail: apiError.detail, instance: apiError.instance, status: apiError.status)
				
			case .imageMapping(let response):
				
				guard let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) else {
					return APIError(description: "MoyaError >> imageMapping", statusCode: response.statusCode, type: nil, title: nil, detail: nil, instance: response.request?.url?.absoluteString, status: nil)
				}
				
				return APIError(description: "MoyaError >> imageMapping >> Server Error Response", statusCode: response.statusCode, type: apiError.type, title: apiError.title, detail: apiError.detail, instance: apiError.instance, status: apiError.status)
				
			case .stringMapping(let response):
				
				guard let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) else {
					return APIError(description: "MoyaError >> stringMapping", statusCode: response.statusCode, type: nil, title: nil, detail: nil, instance: response.request?.url?.absoluteString, status: nil)
				}
				
				return APIError(description: "MoyaError >> stringMapping >> Server Error Response", statusCode: response.statusCode, type: apiError.type, title: apiError.title, detail: apiError.detail, instance: apiError.instance, status: apiError.status)
				
			case .objectMapping(let error, let response):
				
				guard let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) else {
					return APIError(description: "MoyaError >> objectMapping", statusCode: response.statusCode, type: nil, title: nil, detail: nil, instance: response.request?.url?.absoluteString, status: nil)
				}
				
				return APIError(description: "MoyaError >> objectMapping >> Server Error Response", statusCode: response.statusCode, type: apiError.type, title: apiError.title, detail: apiError.detail, instance: apiError.instance, status: apiError.status)
				
			case .encodableMapping(let error):
				
				return APIError(description: "MoyaError >> encodableMapping", statusCode: error.asAFError?.responseCode, type: nil, title: nil, detail: nil, instance: error.asAFError?.url?.absoluteString, status: nil)
				
			case .underlying(let error, let response):
				
				guard let response = response else {
					return APIError(description: "MoyaError >> underlying", statusCode: nil, type: nil, title: nil, detail: nil, instance: nil, status: nil)
				}
				
				guard let apiError = try? JSONDecoder().decode(APIError.self, from: response.data) else {
					return APIError(description: "MoyaError >> underlying", statusCode: response.statusCode, type: nil, title: nil, detail: nil, instance: response.request?.url?.absoluteString, status: nil)
				}
				
				return APIError(description: "MoyaError >> underlying >> Server Error Response", statusCode: response.statusCode, type: apiError.type, title: apiError.title, detail: apiError.detail, instance: apiError.instance, status: apiError.status)
				
			case .requestMapping(let url):
				
				return APIError(description: "MoyaError >> requestMapping", statusCode: nil, type: nil, title: nil, detail: nil, instance: url, status: nil)
				
			case .parameterEncoding(let error):
				
				return APIError(description: "MoyaError >> parameterEncoding", statusCode: error.asAFError?.responseCode, type: nil, title: nil, detail: nil, instance: error.asAFError?.url?.absoluteString, status: nil)
			}
		}
		
		return APIError(description: "MoyaError 아님!! Unexpected Error 발생", statusCode: nil, type: nil, title: nil, detail: nil, instance: nil, status: nil)
	}
}
