//
//  CommunityView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI


struct CommunityView: View {
    
    
    @ObservedObject var vm: PostViewModel = PostViewModel()
    
    
    var body: some View {

        NavigationStack {
            
            floatingActionButton
            
            
        }
        
        
        //        NavigationStack {
//            ZStack(alignment: .bottomTrailing) {
//                GeometryReader { geometry in
//                    VStack {
//                        if vm.communityPosts.isEmpty {
//                            emptyStateView
//                        } else {
//                            communityPostsGrid
//                        }
//                    }
//                    .toolbar {
//                        ToolbarItem {
//                            HStack {
//                                Text("나의 일기")
//                                    .font(.system(size: 20))
//                                    .bold()
//                                    .padding(.leading, 16)
//                                Spacer()
//                            }
//                            .frame(width: geometry.size.width, height: 45)
//                            .background(.white)
//                        }
//                    }
//                }
//                
//                floatingActionButton
//                    .padding(16)
//            }
//        }
    }
    
//    private var emptyStateView: some View {
//        Text("아직 업로드된 글이 없습니다.\n 글쓰기 버튼을 눌러 새로 만드세요.")
//            .multilineTextAlignment(.center)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .offset(y: -20)
//            .background(Color("#EBEBF4"), ignoresSafeAreaEdges: .leading)
//    }
    
//    private var communityPostsGrid: some View {
//        ScrollView {
//            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 24) {
//                ForEach(vm.communityPosts, id: \.self) { communityPost in
//                    CommunityPostPreview(vm: vm, diaryPost: communityPost)
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 24)
//        }
//        .background(Color("#EBEBF4"), ignoresSafeAreaEdges: .leading)
//    }
    
    private var floatingActionButton: some View {
        NavigationLink(destination: CommunityUploadView(vm: vm)) {
            Image(systemName: "pencil")
                .foregroundColor(.white)
                .font(.system(size: 26, weight: .bold))
                .frame(width: 50, height: 50)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(color: .gray, radius: 3, x: 1, y: 1)
        }
    }
    
    
    
    
}
//
