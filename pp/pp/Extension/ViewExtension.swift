//
//  ViewExtensions.swift
//  pp
//
//  Created by 김지현 on 2024/04/04.
//

import SwiftUI

// MARK: - 보더 edge마다 주기
extension View {
	func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
		overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
	}
}

struct EdgeBorder: Shape {
	var width: CGFloat
	var edges: [Edge]
	
	func path(in rect: CGRect) -> Path {
		edges.map { edge -> Path in
			switch edge {
			case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
			case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
			case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
			case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
			}
		}.reduce(into: Path()) { $0.addPath($1) }
	}
}

extension View {
	// MARK: - View를 UIView로 변환
	func asUIView() -> UIView {
		let hostingController = UIHostingController(rootView: self)
		hostingController.view.bounds = UIScreen.main.bounds
		hostingController.view.backgroundColor = .clear
		let uiView = hostingController.view!
		let size = uiView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		uiView.bounds = CGRect(origin: .zero, size: size)
		return uiView
	}
	
	// MARK: - View를 UIImage로 변환
	func snapshot() -> UIImage {
		let controller = UIHostingController(rootView: self)
		let targetSize = CGSize(width: UIScreen.main.bounds.width - 32, height: (UIScreen.main.bounds.width - 32)/7*5)
		let origin = CGPoint(x: 0, y: 0)
		
		controller.view.bounds = CGRect(origin: origin, size: targetSize)
		controller.view.backgroundColor = .clear
		
		let renderer = UIGraphicsImageRenderer(size: targetSize)
		
		return renderer.image { _ in
			controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
		}
	}
}

// MARK: - UIView를 UIImage로 변환
extension UIView {
	func asImage() -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
		defer { UIGraphicsEndImageContext() }
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		layer.render(in: context)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
}
