//
//  EditProfileView.swift
//  pp
//
//  Created by 임재현 on 5/23/24.
//

import SwiftUI

struct EditProfileView<ViewModel: UserViewModelProtocol & PhotoPickerViewModel>: View {
   
    @ObservedObject var vm: ViewModel
    @State private var showModal = false
    @State private var tempNickname: String = ""
    @State private var tempProfileImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let maxPhotosToSelect = 1
    @State private var selectedIndex: Int = 0
    @State private var isShownSheet = false
    @State private var originalProfileImage: UIImage?
    @State private var originalNickname: String = ""
    @State private var isUpdateConfirmed = false

    var body: some View {
        VStack {
            PhotoPickerView(vm: vm,
                            selectedPhotos: $vm.selectedProfile,
                            selectedIndex: $selectedIndex,
                            isShownSheet: $isShownSheet,
                            tempProfileImage: $tempProfileImage,
                            maxPhotosToSelect: maxPhotosToSelect,
                            editingMode: true)

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
                vm.nickname = tempNickname
                if let tempProfileImage = tempProfileImage {
                    vm.profileImage = tempProfileImage
                }

                if vm.presignedRequests.isEmpty {
                    print("Presigned 요청 비어있음")
                } else {
                    if let userIdString = UserDefaults.standard.string(forKey: "UserId"),
                       let userId = Int(userIdString) {
                        vm.updateProfile(userId: userId)
                        isUpdateConfirmed = true
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
            originalNickname = vm.nickname
            tempProfileImage = vm.profileImage
            originalProfileImage = vm.profileImage
        }
        .onDisappear {
            if !isUpdateConfirmed {
                vm.profileImage = originalProfileImage
                vm.nickname = originalNickname
                vm.clearUploadData()
         
            }
           
        }
        .padding()
    }
}
