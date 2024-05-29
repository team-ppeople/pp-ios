//
//  UserPostView.swift
//  pp
//
//  Created by 임재현 on 5/27/24.
//

import SwiftUI

struct UserPostView: View {
    @ObservedObject var vm: UserViewModel = UserViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                GeometryReader { geometry in
                    VStack {
                        if ((vm.userProfile?.posts.isEmpty) != nil) {
                            emptyStateView
                        } else {
                            userPostsGrid
                        }
                    }
                    .toolbar {
                        ToolbarItem {
                            HStack {
                                Text("나의 일기")
                                    .font(.system(size: 20))
                                    .bold()
                                    .padding(.leading, 16)
                                Spacer()
                            }
                            .frame(width: geometry.size.width, height: 45)
                            .background(.white)
                        }
                    }
                }
             
            }
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .center) {
            Image("no.post")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: -30)
    }
    
    private var userPostsGrid: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 24) {
                    ForEach(vm.userProfile!.posts, id: \.self) { diaryPost in
                      //  DiaryPostPreview(vm: vm, diaryPost: diaryPost, size: (geometry.size.width - 56)/2)
                    //   CommunityPostPreview(vm: vm, diaryPost: diaryPost, size: (geometry.size.width - 56)/2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
        }
    }
    
//    private var floatingActionButton: some View {
//        NavigationLink(destination: DiaryUploadView(vm: vm)) {
//            Image(systemName: "pencil")
//                .foregroundColor(.white)
//                .font(.system(size: 26, weight: .bold))
//                .frame(width: 50, height: 50)
//                .background(Color.accentColor)
//                .clipShape(Circle())
//                .shadow(color: .gray, radius: 3, x: 1, y: 1)
//        }
//    }
}
//
//#Preview {
//    DiaryView(vm: DiaryViewModel())
//}
