//
//  DiaryViewCell.swift
//  pp
//
//  Created by 임재현 on 4/15/24.
//

import SwiftUI

struct DiaryPostPreview: View {
    let vm: DiaryViewModel
	let diaryPost: DiaryPost
	
	var body: some View {
		NavigationLink(destination: DiaryDetailView(vm: vm, diaryPost: diaryPost, images: diaryPost.images?.map({ Utils.createImage($0) }) ?? [])) {
			VStack(alignment: .leading) {
				Utils.createImage(diaryPost.images?.first)
					.resizable()
					.scaledToFill()
					.frame(height: 121, alignment: .center)
					.clipShape(
						.rect(
							topLeadingRadius: 10,
							bottomLeadingRadius: 0,
							bottomTrailingRadius: 0,
							topTrailingRadius: 10
						))
				
				Text(diaryPost.title ?? "")
					.font(.system(size: 15))
					.tint(.black)
					.lineLimit(1)
					.frame(height: 18)
					.padding(.horizontal, 10)
				
				Text(Utils.toString(diaryPost.date))
					.font(.system(size: 12))
					.lineLimit(2)
					.foregroundColor(.secondary)
					.frame(height: 15)
					.padding([.horizontal, .bottom], 10)
			}
			.background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
		}
	}
}

#Preview {
	DiaryView(vm: DiaryViewModel())
}
