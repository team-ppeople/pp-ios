//
//  Utils.swift
//  pp
//
//  Created by 김지현 on 2024/04/05.
//

import SwiftUI
import UIKit

class Utils {
	// MARK: - Data to Image
	static func createImage(_ value: Data?) -> Image {
		if let value = value {
			let uiImage: UIImage = UIImage(data: value) ?? UIImage(named: "emty.image")!
			return Image(uiImage: uiImage)
			
		} else {
			return Image(uiImage: (UIImage(named: "emty.image") ?? UIImage(named: "emty.image"))!)
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
}
