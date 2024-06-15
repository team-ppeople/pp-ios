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
            if let profileImageUrl = vm.userProfile?.profileImageUrls {
             
                AsyncImage(url: profileImageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 58, height: 58)
                            .clipShape(Circle())
                            .padding(.leading, 8)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 58, height: 58)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .padding(.leading, 8)
                    case .failure:
                        Image("emty.image")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 58, height: 58)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .padding(.leading, 8)
                    @unknown default:
                        EmptyView()
                    }
                }

            } else {
                Image("emty.image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .padding(.leading, 8)
            }
            
//            Text((((vm.userProfile?.nickname.isEmpty) != nil) ? "바다거북맘" : vm.userProfile?.nickname) ?? "응답 실패")
            Text(vm.nickname.isEmpty ? "" : vm.nickname)
                .font(.title3)
				.tint(.black)
            
            Spacer()
            
            NavigationLink(destination: UserProfileView(vm: vm, userId: nil)) {
                Text("프로필 보기")
                    .frame(width: 93, height: 45)
					.background(.accent)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 8)
    }
}

