//
//  MyProfileView.swift
//  pp
//
//  Created by 임재현 on 5/23/24.
//

import SwiftUI

struct MyProfileView: View {
    @ObservedObject var vm: UserViewModel

    var body: some View {
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
            
            NavigationLink(destination: UserProfileView(vm: vm)) {
                Text("프로필 보기")
                    .frame(width: 93, height: 45)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 8)
    }
}


