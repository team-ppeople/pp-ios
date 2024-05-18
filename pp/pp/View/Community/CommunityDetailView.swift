//
//  CommunityDetailView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct CommunityDetailView: View {
    @ObservedObject var vm: PostViewModel
    let postId: Int
    
    @Environment(\.dismiss) private var dismiss
  
    @State private var showAlert = false
    @State private var showReportConfirmation = false  // 신고 처리 확인용 Alert 표시
 
    var body: some View {
        VStack(alignment: .leading) {

            if let imageUrls = vm.postDetail?.imageUrls, !imageUrls.isEmpty {
                           AutoScroller2(imageURLs: imageUrls)
                               .frame(height: 258)
                       } else {
                           // Placeholder for when there are no images or while loading
                           ProgressView()
                               .frame(height: 258)
                       }
            
            Text(vm.postDetail?.title ?? "title")
                .font(.system(size: 18))
                .padding(.top, 25)
            
            Text(vm.postDetail?.createdDate ?? "date")
                .font(.system(size: 12))
            
            Text(vm.postDetail?.content ?? "content")
                .font(.system(size: 15))
                .padding(.top, 20)
            
            LikeAndReplyView(vm: vm)
            Spacer()
        }
        .onAppear {
            print("Loading post details for postId: \(postId)")
                   vm.loadDetailPosts(postId: postId)
               }
        .padding(.horizontal, 16)
        .padding(.vertical, 25)
        
        .toolbar {
            ToolbarItem {
                Menu {
                    Button(role: .destructive) {
                        showAlert = true
                    } label: {
                      Label("신고", systemImage: "exclamationmark.circle")
                            .frame(width: 22, height: 30)
                    }
                } label: {
                    Image("menu.icon")
                        .frame(width: 22, height: 30)
                }
            }
        }
        .alert("신고 확인", isPresented: $showAlert) {
            Button("확인", role: .destructive) {
                showReportConfirmation = true
                
                // ToDo: - fetchPost에서 각 게시글 Id 받아와서 가지고 있다 신고할때 이 Id 값으로 신고
//                vm.reportPost(postId: <#T##Int#>)
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 게시물을 신고하시겠습니까?")
        }
        .alert("신고 완료", isPresented: $showReportConfirmation) {
            Button("확인", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("신고가 처리되었습니다.")
        }
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
    
    @ObservedObject var vm: PostViewModel
    
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

                
                NavigationLink(destination: PostReplyView(vm: vm)) {
                   
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
