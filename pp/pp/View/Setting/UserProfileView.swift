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
    // let postId: Int
    
    let userId: Int? 
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                if let profileImageUrl = vm.profileImageUrl {
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
                
                Text(vm.nickname.isEmpty ? "" : vm.nickname)
                    .font(.title3)
                
                Spacer()
                
                Button(action: {
                    showModal.toggle()
                }) {
                    Text("프로필 수정")
                        .frame(width: 93, height: 45)
                        .background(.accent)
                        .foregroundColor(.white)
                        .cornerRadius(8)
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
                    
                    if let postcount = vm.userProfile?.postCount {
                        Text("\(postcount)")
                    } else {
                        Text("0")
                    }
                    
                    
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 1, height: 50)
                    .background(Color.gray)
                
                VStack {
                    Text("받은 좋아요 수")
                    
                    
                    if let thumbsUpCount = vm.userProfile?.thumbsUpCount {
                        Text("\(thumbsUpCount)")
                    } else {
                        Text("0")
                    }
                    
                    
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            UserPostView(vm: vm)
            Spacer()
            
        }
        
        .padding(.top, 16)
        .onAppear {
            guard let userId = userId else { return }
            vm.fetchUserProfile(userId: userId)
            
        }
    }
}
