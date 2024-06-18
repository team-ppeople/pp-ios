//
//  PostViewModel.swift
//  pp
//
//  Created by 임재현 on 4/17/24.
//

import SwiftUI
import Combine
import PhotosUI

class CommunityViewModel: PhotoPickerViewModel,UserViewModelProtocol {
    func updateProfile(userId: Int) {
        UserService.shared.updateUserProfile(userId: userId, nickname: nickname, imageUploads:imageUploads, presignedRequests: presignedRequests)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("프로필이 성공적으로 수정되었습니다.")
                    self.fetchUserProfile(userId: userId) // 성공 후 프로필 정보 갱신
                    self.clearUploadData()
                case .failure(_): break
                    //      print("프로필 수정 중 오류 발생: \(error.status), \(error.title)")
                }
            }, receiveValue: {
                print("프로필 수정 완료")
            })
            .store(in: &cancellables)
    }
    
    
    
    func clearUploadData() {
        imageUploads.removeAll()
        presignedRequests.removeAll()
        tempProfileImage = nil
    }
    
    @Published var profileImageUrl: URL?
    
    @Published var nickname: String = ""
    
    @Published var userProfile: UserProfile?
    
    

   
    @Published var tempProfileImage: UIImage?
    
   
    
	private let authService = AuthService.shared
    
    private var cancellables = Set<AnyCancellable>()
	
    @Published var communityPosts: [Post] = []
    @Published var postDetail: PostDetail?
    @Published var title: String = ""
    @Published var contents: String = ""
    @Published var imageUploads = [ImageUpload]()
    @Published var presignedRequests = [PresignedUploadUrlRequests]()
    @Published var isLiked: Bool = false
    @Published var likeCounts: Int = 0
    @Published var commentCounts: Int = 0
    @Published var comments: [Comment] = []
    @Published  var newComment = ""
    
    
    @Published var uiImages: [UIImage] = []
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var profileImage: UIImage?
    @Published var selectedProfile: [PhotosPickerItem] = []
    //MARK: - 이미지 업로드 가능 여부 확인(Presigned-URL)
    func getPresignedId(imageData:[PresignedUploadUrlRequests]) {
        CommunityService.shared.getPresignedId(requestData: imageData)

            .sink { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 작성 완료")
				case .failure(let error):
					print("게시물 작성 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}
            } receiveValue: { response in
				dump("\(response) - error occurs")
				print("Presigned URLs received: \(response)")
            }.store(in: &cancellables)
    }
    
    //MARK: -  작성 완료 버튼 누르면 동작 -> 게시글 작성 API 호출
    func writePost(title: String, content: String) {

		CommunityService.shared.uploadPostWithImages(title: title, content: content, imageUploads: imageUploads, presignedRequests: presignedRequests)
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 작성 완료")
				case .failure(let error):
					print("게시물 작성 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}
			}, receiveValue: {
				print("게시글 생성 완료")
			})
			.store(in: &cancellables)
        }
	
    //MARK: - 글 작성 후 리셋
    func reset() {
		title = ""
		contents = ""
		uiImages.removeAll()
		selectedPhotos.removeAll()
		presignedRequests.removeAll()
		imageUploads.removeAll()
	}

   // MARK: - 새로고침 or 데이터 불러오오면 동작 -> 서버에서 데이터 가져옴
    func loadPosts(limit: Int = 100, lastId: Int?) {

        CommunityService.shared.fetchPosts(limit: limit, lastId: lastId)
            .sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 조회 완료")
				case .failure(let error):
					print("게시물 조회 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}
            }, receiveValue: { response in
                // dump(response)
                self.communityPosts = response.data.posts
            })
            .store(in: &cancellables)
    }
    
    //MARK: - 게시물 상세 불러오기
    func loadDetailPosts(postId: Int) {
        CommunityService.shared.fetchDetailPosts(postId: postId)

            .sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 상세 조회 완료")
				case .failure(let error):
					print("게시물 상세 조회 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}

            }, receiveValue: { response in
                
                self.postDetail = response.data
                self.isLiked = response.data.userActionHistory.thumbsUpped
                self.likeCounts = response.data.thumbsUpCount
                self.commentCounts = response.data.commentCount
                
            })
            .store(in: &cancellables)
    }
    
    //MARK: - 게시물 신고
    func reportPost(postId:Int) {
        CommunityService.shared.reportPost(postId: postId)
            .sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 신고 완료")
				case .failure(let error):
					print("게시물 신고 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    
    //MARK: - 게시물 삭제
    func deletePost(postId: Int) {
        CommunityService.shared.deletePost(postId: postId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("게시글 삭제가 완료되었습니다.")
                case .failure(let error):
                    print("게시글 삭제 중 오류 발생: \(error)")
                }
            }, receiveValue: {
                print("게시글 삭제")
            })
            .store(in: &cancellables)
    }
    
    
    
	
    //MARK: - 게시물 좋아요
    func likePost(postId:Int) {
        CommunityService.shared.thumbsUpPost(postId: postId)
            .sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 좋아요 완료")
				case .failure(let error):
					print("게시물 좋아요 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}
            }, receiveValue: { })
            .store(in: &cancellables)
    }

	
	// MARK: - 게시물 좋아요 취소

    func dislikePost(postId:Int) {
        CommunityService.shared.thumbsSidewayPost(postId: postId)
            .sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 좋아요 취소 완료")
				case .failure(let error):
					print("게시물 좋아요 취소 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}
            }, receiveValue: { })
            .store(in: &cancellables)
    }

	
   //MARK: - 게시물 댓글 불러오기

    func loadComments(postId:Int,limit:Int,lastId:Int?) {
        CommunityService.shared.fetchComments(postId: postId,limit: limit,lastId: lastId)
            .sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 댓글 조회 완료")
				case .failure(let error):
					print("게시물 댓글 조회 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}
            }, receiveValue: { commentsResponse in
                
                self.comments = commentsResponse.data.comments
                print("Comments: \(commentsResponse.data.comments)")
            })
            .store(in: &cancellables)
    }
	
    //MARK: - 게시물 댓글 작성
    func submitComments(postId:Int,content:String) {
        let comments = CommentRequest(content: content)
		
        CommunityService.shared.writeComment(postId: postId, comment: comments)
            .sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 댓글 작성 완료")
				case .failure(let error):
					print("게시물 댓글 작성 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}
            }, receiveValue: { })
            .store(in: &cancellables)
    }
	
    //MARK: - 게시물 댓글 신고
    func reportComment(commentId:Int) {
        CommunityService.shared.reportComments(commentId: commentId)
            .sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished:
					print("게시물 댓글 신고 완료")
				case .failure(let error):
					print("게시물 댓글 신고 Error")
					dump(error)
					
					if error.statusCode == 401 {
						self?.authService.fetchRefreshToken()
					}
				}
            }, receiveValue: { })
            .store(in: &cancellables)
    }
	
    //MARK: - PhotoPicker에서 이미지 선택

    @MainActor
    func addSelectedPhotos() {
        uiImages.removeAll()
        presignedRequests.removeAll()
        imageUploads.removeAll()
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: imageData) {
						let compressedImageData = image.jpegData(compressionQuality: 0.1) ?? Data()
						let imageUpload = ImageUpload(imageData: compressedImageData)
                        let contentLength = compressedImageData.count
                        let contentType = compressedImageData.containsPNGData() ? "image/png" : "image/jpeg"
                        let fileName = "image_\(UUID().uuidString).\(contentType == "image/png" ? "png" : "jpg")"
                        let requestType = "POST_IMAGE"
                        let presignedRequest = PresignedUploadUrlRequests(
                            fileType: requestType, fileName: fileName, fileContentLength: contentLength, fileContentType: contentType
                        )
						
						uiImages.append(image)
                        presignedRequests.append(presignedRequest)
                        imageUploads.append(imageUpload)
						
						print("게시물 이미지 용량 : \(compressedImageData)")
                    }
                }
            }
            selectedPhotos.removeAll()
        }
    }
    
    
   // @MainActor
//       func addSelectedProfile() {
//           guard let profileItem = selectedProfile.first else { return }
//           Task {
//               if let data = try? await profileItem.loadTransferable(type: Data.self),
//                  let image = UIImage(data: data) {
//                   profileImage = image
////                   let imageUpload = ImageUpload(imageData: data)
////                    imageUploads.append(imageUpload)
//                   selectedProfile.removeAll() // 선택된 프로필 이미지 배열을 비웁니다.
//               }
//           }
//       }
    
    @MainActor
    func addSelectedProfile() {
        guard let profileItem = selectedProfile.first else {
            print("No profile item selected")
            return
        }
        
        Task {
            do {
                if let data = try await profileItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    let compressedImageData = image.jpegData(compressionQuality: 0.1) ?? Data()
                    let imageUpload = ImageUpload(imageData: compressedImageData)
                    let contentLength = compressedImageData.count
                    let contentType = compressedImageData.containsPNGData() ? "image/png" : "image/jpeg"
                    let fileName = "image_\(UUID().uuidString).\(contentType == "image/png" ? "png" : "jpg")"
                    let requestType = "PROFILE_IMAGE"
                    let presignedRequest = PresignedUploadUrlRequests(
                        fileType: requestType, fileName: fileName, fileContentLength: contentLength, fileContentType: contentType
                    )
                    
                    profileImage = image
                    presignedRequests.append(presignedRequest)
                    imageUploads.append(imageUpload)
                    selectedProfile.removeAll()
                    
                    print("Presigned request added: \(presignedRequest)") // 추가된 요청 확인
                    print("Image selected \(imageUpload)")
                    print("프로필 이미지 용량 : \(compressedImageData)")
                    //     imageUploads.removeAll()
                } else {
                    print("Failed to load image data")
                }
            } catch {
                print("Error loading profile item: \(error.localizedDescription)")
            }
        }
    }
   
    //MARK: - 프로필 사진 클릭하면 해당 유저 프로필 조회
    func fetchUserProfile(userId: Int) {
       
            UserService.shared.fetchUserProfile(userId: userId)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("유저 프로필을 성공적으로 가져왔습니다.")
                    case .failure(let error):
                        print("유저 프로필 가져오기 중 오류 발생: \(error)")
                    }
                }, receiveValue: { userProfileResponse in
                    self.userProfile = userProfileResponse.data
                    self.nickname = userProfileResponse.data.nickname
                    self.profileImageUrl = userProfileResponse.data.profileImageUrls
                    print("Updated profileImageUrl: \(String(describing: self.profileImageUrl))")
                })
                .store(in: &cancellables)

    }
    
}
    
    
    
extension Data {
    func containsPNGData() -> Bool {
        let pngSignatureBytes: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        let dataBytes = [UInt8](self.prefix(8))
        return pngSignatureBytes == dataBytes
    }
}
