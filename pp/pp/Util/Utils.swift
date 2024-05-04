//
//  Utils.swift
//  pp
//
//  Created by 김지현 on 2024/04/05.
//

import SwiftUI
import UIKit

class Utils {
	static func createImage(_ value: Data?) -> Image {
		if let value = value {
			let uiImage: UIImage = UIImage(data: value) ?? UIImage(named: "emty.image")!
			return Image(uiImage: uiImage)
			
		} else {
			return Image(uiImage: (UIImage(named: "emty.image") ?? UIImage(named: "emty.image"))!)
		}
	}
	
	static func toString(_ date: Date?) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.string(from: date ?? Date())
	}
}
