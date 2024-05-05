//
//  ImageCropper.swift
//  pp
//
//  Created by 김지현 on 2024/05/01.
//

import Mantis
import SwiftUI

enum ImageCropperType {
	case normal
	case noRotaionDial
	case noAttachedToolbar
}

struct ImageCropper: UIViewControllerRepresentable {
	@Binding var image: UIImage
	var cropShapeType: Mantis.CropShapeType = .rect
	var presetFixedRatioType: Mantis.PresetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 7/5)
	var type: ImageCropperType = .normal
	
	@Environment(\.presentationMode) var presentationMode
	
	class Coordinator: CropViewControllerDelegate {
		var parent: ImageCropper
		
		init(_ parent: ImageCropper) {
			self.parent = parent
		}
		
		func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
			parent.image = cropped
			print("transformation is \(transformation)")
			parent.presentationMode.wrappedValue.dismiss()
		}
		
		func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
			parent.presentationMode.wrappedValue.dismiss()
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func makeUIViewController(context: Context) -> UIViewController {
		switch type {
		case .normal:
			return makeNormalImageCropper(context: context)
		case .noRotaionDial:
			return makeImageCropperHiddingRotationDial(context: context)
		case .noAttachedToolbar:
			return makeImageCropperWithoutAttachedToolbar(context: context)
		}
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		
	}
}

extension ImageCropper {
	func makeNormalImageCropper(context: Context) -> UIViewController {
		var config = Mantis.Config()
		config.cropViewConfig.cropShapeType = cropShapeType
		config.presetFixedRatioType = presetFixedRatioType
		let cropViewController = Mantis.cropViewController(image: image,
														   config: config)
		cropViewController.delegate = context.coordinator
		return cropViewController
	}
	
	func makeImageCropperHiddingRotationDial(context: Context) -> UIViewController {
		var config = Mantis.Config()
		config.cropViewConfig.showAttachedRotationControlView = false
		let cropViewController = Mantis.cropViewController(image: image, config: config)
		cropViewController.delegate = context.coordinator
		
		return cropViewController
	}
	
	func makeImageCropperWithoutAttachedToolbar(context: Context) -> UIViewController {
		var config = Mantis.Config()
		config.showAttachedCropToolbar = false
		let cropViewController: CustomViewController = Mantis.cropViewController(image: image, config: config)
		cropViewController.delegate = context.coordinator
		
		return UINavigationController(rootViewController: cropViewController)
	}
}

class CustomViewController: Mantis.CropViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Custom View Controller"
		
		let rotate = UIBarButtonItem(
			image: UIImage.init(systemName: "crop.rotate"),
			style: .plain,
			target: self,
			action: #selector(onRotateClicked)
		)
		
		let done = UIBarButtonItem(
			image: UIImage.init(systemName: "checkmark"),
			style: .plain,
			target: self,
			action: #selector(onDoneClicked)
		)
		
		navigationItem.rightBarButtonItems = [
			done,
			rotate
		]
	}
	
	@objc private func onRotateClicked() {
		didSelectClockwiseRotate()
	}
	
	@objc private func onDoneClicked() {
		crop()
	}
}
