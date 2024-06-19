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
						Image(systemName: "person.fill")
							.resizable()
							.scaledToFill()
							.frame(width: 58, height: 58)
							.clipShape(Circle())
							.background(Circle().foregroundColor(.sub))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 58, height: 58)
                            .clipShape(Circle())
                    case .failure:
						ProgressView()
							.frame(width: 58, height: 58)
							.background(Circle().foregroundColor(.sub))
                    @unknown default:
                        EmptyView()
                    }
                }

            } else {
				Image(systemName: "person.fill")
					.resizable()
					.scaledToFill()
					.frame(width: 58, height: 58)
					.clipShape(Circle())
					.background(Circle().foregroundColor(.sub))
            }
            

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
    }
}

