//
//  UserProfileView.swift
//  pp
//
//  Created by 임재현 on 5/25/24.
//

import SwiftUI

struct UserProfileView: View {
    @State private var showModal = false
    @ObservedObject var vm: UserViewModel

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                if let profileImage = vm.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 58, height: 58)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .padding(.leading, 8)
                } else {
                    Image("empty.image")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 58, height: 58)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .padding(.leading, 8)
                }
                
                Text(vm.nickname.isEmpty ? "바다거북맘" : vm.nickname)
                    .font(.title3)
                
                Spacer()
                
                Button(action: {
                    showModal.toggle()
                }) {
                    Text("프로필 수정")
                        .frame(width: 93, height: 45)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .padding(.trailing, 8)
                .sheet(isPresented: $showModal) {
                    EditProfileView(vm: vm)
                        .presentationDetents([.fraction(5/12)]) // 화면의 5/12 높이로 설정
                        .presentationDragIndicator(.visible) // 드래그 인디케이터를 표시
                        .cornerRadius(40)
                }
            }
            .padding(.horizontal, 8)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal, 32)
                .padding(.top, 16)
            
            HStack(spacing: 0) {
                VStack {
                    Text("게시글수")
                    Text("1")
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 1, height: 50)
                    .background(Color.gray)
                
                VStack {
                    Text("받은 좋아요 수")
                    Text("8")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
            DiaryView()
        }
        .padding(.top, 16)
        
        Spacer()
    }
}





