//
//  ImageDetailView.swift
//  pp
//
//  Created by 임재현 on 4/14/24.
//
import SwiftUI


struct ImageCropView: View {
	@ObservedObject var vm: DiaryViewModel
	@State private var currentPosition: CGSize = .zero
	@State private var newPosition: CGSize = .zero
	@Environment(\.displayScale) var displayScale
	@Environment(\.dismiss) private var dismiss
	
	var index: Int

	var body: some View {
		VStack {
			ZStack {
				image()
				
				Rectangle()
					.fill(Color.black.opacity(0))
					.frame(width: UIScreen.main.bounds.width - 32, height: (UIScreen.main.bounds.width - 32)/7*5)
					.overlay(Rectangle().stroke(Color.white, lineWidth: 3))
			}
		
			HStack {
				Spacer()
				
				Button (action : {
					vm.uiImages[index] = image().snapshot()
					dismiss()
				}) {
					Text("자르기 완료")
						.frame(width: 120, height: 40)
						.background(.accent)
						.foregroundColor(.white)
						.cornerRadius(5)
						.padding(.top, 30)
				}
			}
			.navigationTitle("이미지 자르기")
			.navigationBarTitleDisplayMode(.inline)
		}
		.padding(.vertical, 30)
		.padding(.horizontal, 16)
	}
	
	@ViewBuilder
	func image() -> some View {
		Image(uiImage: vm.uiImages[index])
			.renderingMode(.original)
			.resizable()
			.scaledToFit()
	}
}
