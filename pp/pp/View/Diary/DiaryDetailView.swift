//
//  DiaryDetailView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct DiaryDetailView: View {
    @ObservedObject var diaryPost: DiaryPost = DiaryPost()
    
    var body: some View {
        VStack {
            
            Utils.createImage(diaryPost.images?.first)
                .resizable()
                .frame(width: 171, height: 121)
            Text(diaryPost.title ?? "")
            Text(diaryPost.contents ?? "")
        }
        .toolbar(.hidden, for: .tabBar)
        
    }
}

#Preview {
    DiaryDetailView()
}
