//
//  Utils.swift
//  pp
//
//  Created by 김지현 on 2024/04/05.
//

import Foundation
import Moya

class Utils {
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
            case .underlying(_, let response):
                if let data = response?.data {
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        let detail = json?["detail"] as? String
                        return APIError(description: "MoyaError >> underlying",
                                        statusCode: response?.statusCode,
                                        instance: response?.request?.url?.absoluteString,
                                        detail: detail)
                    } catch {
                        
                        print("JSON parsing error: \(error)")
                        return APIError(description: "JSON parsing error",
                                        statusCode: response?.statusCode,
                                        instance: response?.request?.url?.absoluteString,
                                        detail: nil)
                    }
                } else {
                    
                    return APIError(description: "No data available",
                                    statusCode: response?.statusCode,
                                    instance: response?.request?.url?.absoluteString,
                                    detail: nil)
                }
            default:
                return APIError(description: "Unhandled MoyaError type",
                                statusCode: nil,
                                instance: nil,
                                detail: nil)
            }
        }
        
        return APIError(description: "Unexpected Error Occurred", statusCode: nil, instance: nil)
    }
    
    
    
}
