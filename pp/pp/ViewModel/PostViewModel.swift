//
//  PostViewModel.swift
//  pp
//
//  Created by 임재현 on 4/17/24.
//

import SwiftUI
import Combine
import PhotosUI

class PostViewModel: PhotoPickerViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    @Published var communityPosts: [Post] = []
    @Published var postDetail: PostDetail?
    @Published var title: String = ""
    @Published var contents: String = ""
    @Published var uiImages: [UIImage] = []
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var presignedRequests = [PresignedIdRequest]()
  
    @Published var communityPostSample: [CommunityPostSample] = [
    
        CommunityPostSample(image:UIImage(named: "emty.image")!, title: "안녕하세요1", contents: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nisl tincidunt eget nullam non. Quis hendrerit dolor magna eget est lorem ipsum dolor sit. Volutpat odio facilisis mauris sit amet massa. Commodo odio aenean sed adipiscing diam donec adipiscing tristique. Mi eget mauris pharetra et. Non tellus orci ac auctor augue. Elit at imperdiet dui accumsan sit. Ornare arcu dui vivamus arcu felis. Egestas integer eget aliquet nibh praesent. In hac habitasse platea dictumst quisque sagittis purus. Pulvinar elementum integer enim neque volutpat ac.", createDate: "2024-05-01"),
        CommunityPostSample(image:UIImage(named: "launch.icon")!, title: "안녕하세요2", contents: "안녕안녕안녕안녕2", createDate: "2024-05-02"),
        CommunityPostSample(image:UIImage(named: "apple.login.icon")!, title: "안녕하세요3", contents: "안녕안녕안녕안녕3", createDate: "2024-05-03"),
        CommunityPostSample(image:UIImage(named: "emty.image")!, title: "안녕하세요4", contents: "안녕안녕안녕안녕4", createDate: "2024-05-04")
        
    ]
    
    @Published var selectedPost: CommunityPostSample?
    
    //MARK: -  작성 완료 버튼 누르면 동작 -> 게시글 작성 API 호출
    
    func writePost(title:String,content:String,imageData:[PresignedIdRequest]) {
        CommunityService.shared.uploadPostWithImages(title: title, content: content, imageData: presignedRequests)
            .sink(receiveCompletion: { completion in
                // 완료 상태를 확인
                print("completion\(completion)")
                switch completion {
                case .finished:
                    print("게시글이 성공적으로 생성되었습니다.")
                case .failure(let error):
                    print("게시글 생성 중 오류 발생: \(error.status),\(error.title)")
                    if error.status == 400{
                        print("인증 오류, 재로그인 필요")
                        
                    }
                    
                }
            }, receiveValue: {
                
                print("게시글 생성 완료")
                
            })
            .store(in: &cancellables)
    }
    
    func getPresignedId(imageData:[PresignedIdRequest]) {
        
        CommunityService.shared.getPresignedId(requestData: imageData)
            .sink { completion in
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error getting presigned IDs: \(error)")
                }
            } receiveValue: { response in
                
                print("Presigned URLs received: \(response)")
            }.store(in: &cancellables)
    }
    
    
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
                self.communityPosts = response.data.posts
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
    //MARK: - PhotoPicker에서 이미지 선택
    
    @MainActor
    func addSelectedPhotos() {
        uiImages.removeAll()
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            uiImages.append(image)
                            let contentLength = imageData.count
                            let contentType = imageData.containsPNGData() ? "image/png" : "image/jpeg"
                            let requestType = "POST_IMAGE"
                            let presignedRequest = PresignedIdRequest(
                                fileUploadRequestType: requestType,
                                fileContentLength: contentLength,
                                fileContentType: contentType
                            )
                            presignedRequests.append(presignedRequest)
                        }
                    }
                }
            }
            selectedPhotos.removeAll()
            
        }
    }
}
extension Data {
    func containsPNGData() -> Bool {
        let pngSignatureBytes: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        let dataBytes = [UInt8](self.prefix(8))
        return pngSignatureBytes == dataBytes
    }
}
