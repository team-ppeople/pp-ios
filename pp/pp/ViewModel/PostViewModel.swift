//
//  PostViewModel.swift
//  pp
//
//  Created by 임재현 on 4/17/24.
//

import SwiftUI
import Combine

class PostViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var posts: [Post] = []
    @Published var postDetail: PostDetail?
    
    // 작성 완료 버튼 누르면 동작 -> 게시글 작성 API 호출
    func submitPost(title: String, content: String, imageIds: [Int]) {
        let post = PostRequest(title: title, content: content, postImageFileUploadIds: imageIds)
        CommunityService.shared.createPost(post: post)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Post was successfully created")
                case .failure(let error):
                    print("Error creating post: \(error)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    
    // 새로고침 or 데이터 불러오오면 동작 -> 서버에서 데이터 가져옴
    func loadPosts(limit: Int = 20, lastId: Int?) {
        CommunityService.shared.fetchPosts(limit: limit, lastId: lastId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching posts: \(error)")
                }
            }, receiveValue: { response in
                self.posts = response.data.posts
            })
            .store(in: &cancellables)
    }
    
    
    func loadDetailPosts(postId: Int) {
           CommunityService.shared.fetchDetailPosts(postId: postId)
               .sink(receiveCompletion: { completion in
                   if case .failure(let error) = completion {
                       print("\(error.status):Error \(error.title) occurs because : \(error.detail)")
                   }
               }, receiveValue: { response in
                   self.postDetail = response.data.post
               })
               .store(in: &cancellables)
       }
    
}
