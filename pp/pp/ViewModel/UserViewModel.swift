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

class UserViewModel: PhotoPickerViewModel {
    var uiImages: [UIImage] = []

    var selectedPhotos: [PhotosPickerItem]  = []
    @Published var imageUploads = [ImageUpload]()
    @Published var tempProfileImage: UIImage? 

    func addSelectedPhotos() {
        print("hi")
    }

    private var cancellables = Set<AnyCancellable>()

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
                    profileImage = image

                    let contentLength = data.count
                    let contentType = data.containsPNGData() ? "image/png" : "image/jpeg"
                    let fileName = "image_\(UUID().uuidString).\(contentType == "image/png" ? "png" : "jpg")"
                    let requestType = "PROFILE_IMAGE"
                    let presignedRequest = PresignedUploadUrlRequests(
                        fileType: requestType, fileName: fileName, fileContentLength: contentLength, fileContentType: contentType
                    )

                    presignedRequests.append(presignedRequest)

                    let imageUpload = ImageUpload(imageData: data)
                    imageUploads.append(imageUpload)


                    print("Presigned request added: \(presignedRequest)") // 추가된 요청 확인
                    print("Image selected \(imageUpload)")
                    selectedProfile.removeAll()
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

    // 유저 탈퇴
    func deleteUser(userId: Int) {
        UserService.shared.deleteUser(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("회원 탈퇴가 완료되었습니다.")
                case .failure(let error):
                    print("유저 탈퇴 중 오류 발생: \(error)")
                }
            }, receiveValue: {
                print("유저 탈퇴")
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
}
////
////
//
//
