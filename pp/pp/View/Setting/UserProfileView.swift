//
//  UserProfileView.swift
//  pp
//
//  Created by 임재현 on 5/25/24.
//

import SwiftUI


struct UserProfileView<ViewModel: UserViewModelProtocol>: View {
    @State private var showModal = false
    @ObservedObject var vm: ViewModel
    // let postId: Int
    @State private var showMenu = false
    @State private var showAlert = false
    let userId: Int?
	@State private var alertMessage: String = ""
	@Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                if let profileImageUrl = vm.profileImageUrl {
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
                
                Text(vm.nickname.isEmpty ? "닉네임 불러오기 실패" : vm.nickname)
                    .font(.title3)
                
                Spacer()
                
                let currentUserId = UserDefaults.standard.string(forKey: "UserId").flatMap(Int.init)
                
                // 프로필 수정 버튼 표시 조건
                if type(of: vm) == UserViewModel.self || (type(of: vm) == CommunityViewModel.self && userId == currentUserId) {
                    Button(action: {
                        showModal.toggle()
                    }) {
                        Text("프로필 수정")
                            .frame(width: 93, height: 45)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 8)
                    .sheet(isPresented: $showModal) {
                        if let userVM = vm as? UserViewModel {
                            EditProfileView(vm: userVM)
                                .presentationDetents([.fraction(5/12)]) // 화면의 5/12 높이로 설정
                                .presentationDragIndicator(.visible) // 드래그 인디케이터를 표시
                                .cornerRadius(40)
                        }
                        
                        if let vm = vm as? CommunityViewModel {
                            EditProfileView(vm: vm)
                            
                                .presentationDetents([.fraction(5/12)]) // 화면의 5/12 높이로 설정
                                .presentationDragIndicator(.visible) // 드래그 인디케이터를 표시
                                .cornerRadius(40)
                        }
                        
                        
                    }
                }
                
                else {
                    Button(action: {
                        self.showMenu.toggle()
                    }) {
                        Image("menu.icon")
                            .imageScale(.large)
                    }
                    .padding(.trailing, 16)
                    .buttonStyle(PlainButtonStyle())
                    .background(
                        VStack {
                            if showMenu {
                                Button("차단") {
                                    
                                    if let vm = vm as? CommunityViewModel,let userId = userId{
										vm.blockUsers(userId: userId) { isBlocked in
											self.showMenu = false
											self.showAlert = true
											
											if isBlocked {
												self.alertMessage = "유저가 차단되었습니다."
											} else {
												self.alertMessage = "유저를 차단하는데 오류가 발생했습니다. 다시 시도해주세요."
											}
										}
                                       // vm.unblockUsers(userId: 13)
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity)
                                .padding(5)
                                .frame(width: 100)
                                .frame(height: 40)
                                .background(Color.white)
                                .cornerRadius(5)
                                //  .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            }
                        }
                            .offset(x: -55, y: 32)
                        
                    )
                }
                
                
                
            }
            .padding(.horizontal, 8)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal, 16)
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
//            blockStateView
            Spacer()
            
        }
        
        .padding(.top, 16)
        .onAppear {
            guard let userId = userId else { return }
            print("유저아이디\(userId)")
            vm.fetchUserProfile(userId: userId)
        }
		.alert(isPresented: $showAlert) {
			Alert(
				title: Text(""),
				message: Text(alertMessage),
				dismissButton: .default(Text("OK"), action: {
					dismiss()
				})
			)
		}
    }
    
    
    private var blockStateView: some View {
        VStack {
            Image("block")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.secondary)
                .padding(.top, 120)
            
            Text("차단된 사용자 입니다.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 16)
            
            Text("게시물을 보려면 차단을 해제해주세요.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 0)
            
            Spacer()
        }

    }
    
    
    
    
    
    
    
}
