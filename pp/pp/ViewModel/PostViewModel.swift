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
    
    //MARK: -  작성 완료 버튼 누르면 동작 -> 게시글 작성 API 호출
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
    
    //MARK: - 새로고침 or 데이터 불러오오면 동작 -> 서버에서 데이터 가져옴
    func loadPosts(limit: Int = 20, lastId: Int?) {
        CommunityService.shared.fetchPosts(limit: limit, lastId: lastId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("[loadPosts]\(error.status):Error \(error.title) occurs because : \(error.detail)")
                }
            }, receiveValue: { response in
                self.posts = response.data.posts
            })
            .store(in: &cancellables)
    }
    
    //MARK: - 게시물 상세 불러오기
    func loadDetailPosts(postId: Int) {
        CommunityService.shared.fetchDetailPosts(postId: postId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("[loadDetailPost]\(error.status):Error \(error.title) occurs because : \(error.detail)")
                }
            }, receiveValue: { response in
                self.postDetail = response.data.post
            })
            .store(in: &cancellables)
    }
    
    //MARK: - 게시물 신고
    
    func reportPost(postId:Int) {
        CommunityService.shared.reportPost(postId: postId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Report was successfully created")
                case .failure(let error):
                    print("Error reporting post: \(error.detail)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    //MARK: - 게시물 좋아요
    func likePost(postId:Int) {
        CommunityService.shared.thumbsUpPost(postId: postId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("like Post was successfully created")
                case .failure(let error):
                    print("Error reporting post: \(error.detail)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    //MARK: - 게시물 좋아요 취소
    func dislikePost(postId:Int) {
        CommunityService.shared.thumbsSidewayPost(postId: postId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("dislike Post was successfully created")
                case .failure(let error):
                    print("Error reporting post: \(error.detail)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    //MARK: - 게시물 댓글 불러오기
    func loadComments(postId:Int,limit:Int,lastId:Int?) {
        CommunityService.shared.fetchComments(postId: postId,limit: limit,lastId: lastId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched comments")
                case .failure(let error):
                    print("Failed to fetch comments: \(error)")
                }
            }, receiveValue: { commentsResponse in
                print("Comments: \(commentsResponse.data.comments)")
            })
            .store(in: &cancellables)
    }
    //MARK: - 게시물 댓글 작성
    func submitComments(postId:Int,content:String) {
        let comments = CommentRequest(content: content)
        CommunityService.shared.writeComment(postId: postId, comment: comments)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Comments was successfully created")
                case .failure(let error):
                    print("Error creating post: \(error)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    //MARK: - 게시물 댓글 신고
    
    func reportComment(commentId:Int) {
        CommunityService.shared.reportComments(commentId: commentId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Report Comments were successfully created")
                case .failure(let error):
                    print("Error reporting post: \(error.detail)")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
}
