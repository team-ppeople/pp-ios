//
//  UserPostView.swift
//  pp
//
//  Created by 임재현 on 5/27/24.
//

import SwiftUI

struct UserPostView<ViewModel: UserViewModelProtocol>: View {
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                GeometryReader { geometry in
                    VStack {
                        if let posts = vm.userProfile?.posts, !posts.isEmpty {
                            userPostsGrid(posts: posts)
                        } else {
                            emptyStateView
                        }
                    }
                    .toolbar {
                        ToolbarItem {
                            HStack {
                                Text("프로필")
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
    
    private func userPostsGrid(posts: [Post]) -> some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 24) {
                    ForEach(posts, id: \.id) { post in
                        UserPostPreview(post: post, size: abs((geometry.size.width - 56) / 2))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
