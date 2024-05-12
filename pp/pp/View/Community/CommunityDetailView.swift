//
//  CommunityDetailView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct CommunityDetailView: View {
    @ObservedObject var vm: PostViewModel
    var postDetail: CommunityPostSample
    @Environment(\.dismiss) private var dismiss
    
    let imageURLs: [URL?]
   // let images: [Image]
    
    var body: some View {
        VStack {
            if !imageURLs.compactMap({ $0 }).isEmpty {
            AutoScroller2(imageURLs: imageURLs.compactMap { $0 })
                    .frame(height: 258)
            }
            
            Text(postDetail.title)
            //Text(vm.postDetail?.title ?? "")
            //Text("제목")
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 25)
            Text(postDetail.createDate)
                //  Text(vm.postDetail?.createDate ?? "")
            //Text("날짜")
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(postDetail.contents)
            //Text(vm.postDetail?.content ?? "")
            //Text("날짜")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 25)
        .toolbar {
            ToolbarItem {
                Menu {
                    Button("신고") {
                        //Todd: -  신고하기 버튼 
//                        vm.deleteDiaryPost(diaryPost)
                        dismiss()
                    }
                } label: {
                    Image("menu.icon")
                        .frame(width: 22, height: 30)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}
////#Preview {
////    CommunityDetailView()
////}
struct AutoScroller2: View {
    var imageURLs: [URL]

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()

            TabView {
                ForEach(imageURLs, id: \.self) { url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 258)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 258)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
    }
}
