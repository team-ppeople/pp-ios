//
//  ColorExtensions.swift
//  pp
//
//  Created by 김지현 on 2024/04/04.
//

import SwiftUI

// MARK: - HexColor 나타내기
extension Color {
	init(_ hex: String) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
		
		var rgb: UInt64 = 0
		
		Scanner(string: hexSanitized).scanHexInt64(&rgb)
		
		let red = Double((rgb & 0xFF0000) >> 16) / 255.0
		let green = Double((rgb & 0x00FF00) >> 8) / 255.0
		let blue = Double(rgb & 0x0000FF) / 255.0
		
		self.init(red: red, green: green, blue: blue)
	}
}

// MARK: - Color Asset 사용하기 (SwiftUI - Color)
extension Color {
	static let subColor = Color("SubColor")
	static let darkSubColor = Color("DarkSubColor")
	static let kakaoColor = Color("KakaoColor")
}

// MARK: - Color Asset 사용하기 (UIKit - UIColor)
extension UIColor {
	class var subColor: UIColor {
		return UIColor(named: "SubColor") ?? UIColor.gray
	}
	class var darkSubColor: UIColor {
        return UIColor(named: "DarkSubColor") ?? UIColor.darkGray
	}
}
