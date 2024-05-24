//
//  EditProfileView.swift
//  pp
//
//  Created by 임재현 on 5/23/24.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var vm: CommunityViewModel
   
    @State private var showModal = false
    @State var nickName: String = ""
    @Environment(\.presentationMode) var presentationMode
    let maxPhotosToSelect = 1
    @State private var selectedIndex: Int = 0
    @State private var isShownSheet = false
    
    var body: some View {
        VStack {
            PhotoPickerView<CommunityViewModel>(
                vm: vm,
                selectedPhotos: $vm.selectedProfile,
                selectedIndex: $selectedIndex,
                isShownSheet: $isShownSheet,
                maxPhotosToSelect: maxPhotosToSelect,
                editingMode: true
            )
            
            TextField("닉네임", text: $nickName)
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
        .padding()
    }
}
