//
//  DiaryViewCell.swift
//  pp
//
//  Created by 임재현 on 4/15/24.
//

import SwiftUI

struct DiaryPostPreview: View {
    let diaryPost: DiaryPost

    var body: some View {
        NavigationLink(destination: DiaryDetailView(diaryPost: diaryPost)) {
            VStack(alignment: .leading) {
                Utils
                .createImage(diaryPost.images?.first)
                .resizable()
                .scaledToFill()
                .frame(width: 171, height: 121, alignment: .top)
                .clipped()
                
                
            Text(diaryPost.title ?? "제목 없음")
                .font(.headline)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .frame(height: 20)
                
            Text(diaryPost.contents ?? "내용 없음")
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
                .padding([.horizontal, .bottom], 10)
                .frame(height: 40)
             }
                .frame(width: 171, height: 181)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.white))
        }
    }
}
