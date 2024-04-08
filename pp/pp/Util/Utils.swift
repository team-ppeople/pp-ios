//
//  Utils.swift
//  pp
//
//  Created by 김지현 on 2024/04/05.
//

import SwiftUI
import UIKit

class Utils {
	static func createImage(_ value: Data) -> Image {
		#if canImport(UIKit)
			let songArtwork: UIImage = UIImage(data: value) ?? UIImage()
			return Image(uiImage: songArtwork)
		#elseif canImport(AppKit)
			let songArtwork: NSImage = NSImage(data: value) ?? NSImage()
			return Image(nsImage: songArtwork)
		#else
			return Image(systemImage: "some_default")
		#endif
	}
}