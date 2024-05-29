//
//  EditProfileView.swift
//  pp
//
//  Created by 임재현 on 5/23/24.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var vm: UserViewModel
    @State private var showModal = false
    @State private var tempNickname: String = ""
    @State private var tempProfileImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let maxPhotosToSelect = 1
    @State private var selectedIndex: Int = 0
    @State private var isShownSheet = false

    var body: some View {
        VStack {
            PhotoPickerView<UserViewModel>(
                vm: vm,
                selectedPhotos: $vm.selectedProfile,
                selectedIndex: $selectedIndex,
                isShownSheet: $isShownSheet,
                tempProfileImage: $tempProfileImage,
                maxPhotosToSelect: maxPhotosToSelect,
                editingMode: true
            )

            TextField("닉네임", text: $tempNickname)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .frame(width: 182)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
                .padding()

            Button(action: {
                // 유저 정보 수정 호출
                vm.nickname = tempNickname
                if let tempProfileImage = tempProfileImage {
                    vm.profileImage = tempProfileImage // 이미지 업데이트
                }
                
                if vm.presignedRequests.isEmpty {
                    print("Presigned 요청 비어있음")
                } else {
                    if let userIdString = UserDefaults.standard.string(forKey: "UserId"),
                       let userId = Int(userIdString) {
                        vm.updateProfile(userId: userId)
                    } else {
                        print("UserId 찾을수 없음")
                    }
                }
                
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("수정 완료")
                    .foregroundColor(.white)
                    .frame(width: 337, height: 50)
                    .background(Color.yellow)
                    .cornerRadius(5)
            }
            .padding(.top, 10)
        }
        .onAppear {
            tempNickname = vm.nickname
            tempProfileImage = vm.profileImage 
                 // 프로필 이미지 설정
            
            print("onappear")
        }
        .onDisappear {
            //            vm.clearUploadData()
            /*tempProfileImage = UIImage(systemName: "person.fill") */  // EditProfileView가 dismiss될 때 초기화
          print("disappear")
            
        }
        .padding()
    }
}



