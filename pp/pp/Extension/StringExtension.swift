//
//  IntExtension.swift
//  pp
//
//  Created by 김지현 on 2024/05/01.
//

import Foundation

extension String: Identifiable {
	public var id: String { self }
	
	func toDate() -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		if let date = dateFormatter.date(from: self) {
			return date
		} else {
			return nil
		}
	}
}
