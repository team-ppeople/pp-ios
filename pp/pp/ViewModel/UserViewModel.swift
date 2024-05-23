//
//  UserViewModel.swift
//  pp
//
//  Created by 임재현 on 5/23/24.
//

import Combine


class UserViewModel:ObservableObject {
    
    
    
    //MARK: - 유저 정보 수정
    private var cancellables = Set<AnyCancellable>()
       @Published var nickname: String = ""
       @Published var profileImageFileUploadId: Int = 0

       func editUserInfo(userId: Int) {
           let profile = EditProfileRequest(nickname: nickname, profileImageFileUploadId: profileImageFileUploadId)
           UserService.shared.editUserInfo(userId: userId, profile: profile)
               .sink(receiveCompletion: { completion in
                   switch completion {
                   case .finished:
                       print("유저 정보가 성공적으로 수정되었습니다.")
                   case .failure(let error):
                       print("유저 정보 수정 중 오류 발생: \(error)")
                   }
               }, receiveValue: {
                   print("유저 정보 수정 완료")
               })
               .store(in: &cancellables)
       }
}
