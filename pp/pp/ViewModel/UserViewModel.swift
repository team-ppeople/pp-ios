//
//  UserViewModel.swift
//  pp
//
//  Created by 임재현 on 5/23/24.
//

import Combine


class UserViewModel:ObservableObject {
    
    
    private var cancellables = Set<AnyCancellable>()
    @Published var nickname: String = ""
    @Published var profileImageFileUploadId: Int = 0
    
    
//    //MARK: - 유저 정보 수정
//    func editUserInfo(userId: Int) {
//        let profile = EditProfileRequest(nickname: nickname, profileImageFileUploadId: profileImageFileUploadId)
//        UserService.shared.editUserInfo(userId: userId, profile: profile)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    print("유저 정보가 성공적으로 수정되었습니다.")
//                case .failure(let error):
//                    print("유저 정보 수정 중 오류 발생: \(error)")
//                }
//            }, receiveValue: {
//                print("유저 정보 수정 완료")
//            })
//            .store(in: &cancellables)
//    }
//    //MARK: - 유저 탈퇴
//    func deleteUser(userId:Int) {
//        UserService.shared.deleteUser(userId: userId)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    print("회원 탈퇴가 완료되었습니다.")
//                case .failure(let error):
//                    print("유저 탈퇴 중 오류 발생: \(error)")
//                }
//            }, receiveValue: {
//                print("유저 탈퇴")
//            })
//            .store(in: &cancellables)
//    }
//    //MARK: - 유저 정보 불러오기
//    func fetchUserProfile(userId: Int) {
//        UserService.shared.fetchUserProfile(userId: userId)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    print("유저 프로필을 성공적으로 가져왔습니다.")
//                case .failure(let error):
//                    print("유저 프로필 가져오기 중 오류 발생: \(error)")
//                }
//            }, receiveValue: { userProfileResponse in
//                //     self.userProfile = userProfileResponse.data.user
//                //   print("유저 프로필: \(String(describing: self.userProfile))")
//            })
//            .store(in: &cancellables)
//    }
//    
//    func fetchUserPosts(userId: Int, limit: Int = 20, lastId: Int? = nil) {
//          UserService.shared.fetchUserPosts(userId: userId, limit: limit, lastId: lastId)
//              .sink(receiveCompletion: { completion in
//                  switch completion {
//                  case .finished:
//                      print("유저 게시글을 성공적으로 가져왔습니다.")
//                  case .failure(let error):
//                      print("유저 게시글 가져오기 중 오류 발생: \(error)")
//                  }
//              }, receiveValue: { userPostsResponse in
////                  self.userPosts = userPostsResponse.data.posts
////                  print("유저 게시글: \(self.userPosts)")
//              })
//              .store(in: &cancellables)
//      }
//    
//    
    
}
