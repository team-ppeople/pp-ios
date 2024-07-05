//
//  UserViewModel.swift
//  pp
//
//  Created by 임재현 on 5/23/24.
//
//
import Combine
import UIKit
import _PhotosUI_SwiftUI



protocol UserViewModelProtocol: ObservableObject {
    var profileImageUrl: URL? { get }
    var nickname: String { get set }
    var userProfile: UserProfile? { get }
    var profileImage: UIImage? { get set }
    var selectedProfile: [PhotosPickerItem] { get set }
    var presignedRequests: [PresignedUploadUrlRequests] { get }
    func fetchUserProfile(userId: Int)
    func updateProfile(userId: Int)
    func clearUploadData()
}

class UserViewModel: PhotoPickerViewModel,UserViewModelProtocol {
    var uiImages: [UIImage] = []
    
    var selectedPhotos: [PhotosPickerItem]  = []
    @Published var imageUploads = [ImageUpload]()
    @Published var tempProfileImage: UIImage?
    
    func addSelectedPhotos() {
        print("hi")
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var notices: [Notice] = []
    @Published var nickname: String = ""
    @Published var profileImageFileUploadId: Int = 0
    @Published var profileImage: UIImage?
    @Published var selectedProfile: [PhotosPickerItem] = []
    @Published var userProfile: UserProfile?
    @Published var profileImageUrl: URL? {
        didSet {
            if let profileImageUrl = profileImageUrl {
                Task {
                    if let data = try? Data(contentsOf: profileImageUrl), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileImage = image
                        }
                    }
                }
            }
        }
    }
    @Published var presignedRequests = [PresignedUploadUrlRequests]()
    
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
    func updateProfile(userId: Int) {
        if presignedRequests.isEmpty {
            let profile = EditProfileRequest(nickname: nickname, profileImageFileUploadId: nil)
            UserService.shared.editUserInfo(userId: userId, profile: profile)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("닉네임이 성공적으로 수정되었습니다.")
                        self.fetchUserProfile(userId: userId)
                    case .failure(_):
                        print("닉네임 수정 중 오류 발생")
                    }
                }, receiveValue: {
                    print("닉네임 수정 완료")
                })
                .store(in: &cancellables)
        } else {
  
            UserService.shared.updateUserProfile(userId: userId, nickname: nickname, imageUploads: imageUploads, presignedRequests: presignedRequests)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("프로필이 성공적으로 수정되었습니다.")
                        self.fetchUserProfile(userId: userId)
                        self.clearUploadData()
                    case .failure(_):
                        print("프로필 수정 중 오류 발생")
                    }
                }, receiveValue: {
                    print("프로필 수정 완료")
                })
                .store(in: &cancellables)
        }
    }

	
	func clearUploadData() {
		imageUploads.removeAll()
		presignedRequests.removeAll()
		tempProfileImage = nil
        profileImage = nil
        selectedPhotos.removeAll()
        selectedProfile.removeAll()
	}
	
	// 로그아웃
	func logout() {
		AuthService.shared.logInSubject.send(false)
		AuthService.shared.logOutSubject.send(true)
		
		UserDefaults.standard.set(nil, forKey: "AccessToken")
		UserDefaults.standard.set(nil, forKey: "RefreshToken")
		UserDefaults.standard.set(nil, forKey: "UserId")
		UserDefaults.standard.set(nil, forKey: "ClientId")
	}


    // 유저 탈퇴
    func deleteUser() {
		let userId = Int(UserDefaults.standard.string(forKey: "UserId") ?? "") ?? 0
		
        UserService.shared.deleteUser(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("회원 탈퇴가 완료되었습니다.")
                case .failure(let error):
                    print("유저 탈퇴 중 오류 발생: \(error)")
                }
            }, receiveValue: { [weak self] in
                print("유저 탈퇴")
				
				self?.logout()
            })
            .store(in: &cancellables)
    }
    
    // 유저 프로필 조회
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
    
    // 유저 게시글 조회
    func fetchUserPosts(userId: Int, limit: Int = 20, lastId: Int? = nil) {
        UserService.shared.fetchUserPosts(userId: userId, limit: limit, lastId: lastId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("유저 게시글을 성공적으로 가져왔습니다.")
                case .failure(let error):
                    print("유저 게시글 가져오기 중 오류 발생: \(error)")
                }
            }, receiveValue: { userPostsResponse in
                // self.userPosts = userPostsResponse.data.posts
                // print("유저 게시글: \(self.userPosts)")
            })
            .store(in: &cancellables)
    }
    
    
    
    func fetchNotices(limit: Int = 20, lastId: Int? = nil) {
        UserService.shared.fetchNotices( limit: limit, lastId: lastId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("유저 게시글을 성공적으로 가져왔습니다.")
                case .failure(let error):
                    print("유저 게시글 가져오기 중 오류 발생: \(error)")
                }
            }, receiveValue: { noticesResponse in
                print(noticesResponse)
               self.notices = noticesResponse.data.notices
                // print("공지사항: \(self.noticesResponse)")
            })
            .store(in: &cancellables)
    }
    
    func blockUsers(userId:Int) {
        UserService.shared.blockUsers(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("유저 차단이 완료되었습니다.")
                case .failure(let error):
                    print("유저 차단 중 오류 발생: \(error)")
                }
            }, receiveValue: {
                print("유저 차단")
            })
            .store(in: &cancellables)
    }
    
    func unblockUsers(userId:Int) {
        UserService.shared.unblockUsers(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("유저 차단 해제가 완료되었습니다.")
                case .failure(let error):
                    print("유저 차단 해제 중 오류 발생: \(error)")
                }
            }, receiveValue: {
                print("유저 차단 해제")
            })
            .store(in: &cancellables)
    }
    
    
}
