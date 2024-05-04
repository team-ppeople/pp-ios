//
//  ImageExtension.swift
//  pp
//
//  Created by 김지현 on 2024/04/05.
//

import SwiftUI

extension Image {
//	func toData()-> Data {
//		return self.toUIImage().jpegData(compressionQuality: 1)!
//	}
}

// MARK: - SwiftUI View를 UIImage로 변환하는 확장
extension UIImage {
	convenience init(view: UIView) {
		UIGraphicsBeginImageContext(view.frame.size)
		view.layer.render(in: UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.init(cgImage: (image?.cgImage)!)
	}
}

