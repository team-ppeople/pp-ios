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
    let images: [Image] = [Image(uiImage: UIImage(named: "AppIcon")!),
                           Image(uiImage: UIImage(named: "emty.image")!),
                           Image(uiImage: UIImage(named: "AppIcon")!),
                           Image(uiImage: UIImage(named: "apple.login.icon")!),
                           Image(uiImage: UIImage(named: "AppIcon")!)]
    
    var body: some View {
        VStack(alignment:.leading) {
//            if !imageURLs.compactMap({ $0 }).isEmpty {
//            AutoScroller2(imageURLs: imageURLs.compactMap { $0 })
//                    .frame(height: 258)
//            }
//            
            if images.count != 0 {
                AutoScroller(images: images)
                    .frame(height: 258)
            }
            
            
            Text(postDetail.title)
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 25)
            Text(postDetail.createDate)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(postDetail.contents)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
            
            LikeAndReplyView()
            
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


struct LikeAndReplyView: View {
    
    @State var isLiked:Bool = false
    @State var likeCounts:Int = 0
    @State var replyCounts:Int = 0
    
    var body: some View {
        
        NavigationStack {
            HStack {
                
                Button {
                    self.isLiked.toggle()
                    
                    if isLiked {
                        print("좋아요")
                        likeCounts += 1
                    } else {
                        print("좋아요 취소")
                        likeCounts -= 1
                    }
                    
                } label: {
                   
                    HStack {
                        Text("좋아요")
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .black)
                
                    }
                }

                Text("\(likeCounts)")

                
                NavigationLink(destination: PostReplyView()) {
                   
                    HStack {
                        Text("댓글")
                        Image(systemName: "bubble")
                    }
                  
                }
                Text("\(replyCounts)")
            }
        }
        

        
    }
}
