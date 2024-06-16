//
//  CommunityDetailView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct CommunityDetailView: View {
    @ObservedObject var vm: CommunityViewModel
    let postId: Int
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    @State private var showReportConfirmation = false
    @State private var showDeleteAlert = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let imageUrls = vm.postDetail?.imageUrls, !imageUrls.isEmpty {
                    AutoScroller2(imageURLs: imageUrls, size: UIScreen.main.bounds.width - 32)
                        .frame(height: UIScreen.main.bounds.width - 32)
                        .padding(.top, 20)
                } else {
                    ProgressView()
                        .frame(height: UIScreen.main.bounds.width - 32)
                }
                HStack {
                    //                    NavigationLink(destination: UserProfileView(vm: UserViewModel(), userId: vm.postDetail?.createdUser.id)) {
                    if let profileImageUrl = vm.postDetail?.createdUser.profileImageURL {
                        AsyncImage(url: profileImageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 35, height: 35)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 35, height: 35)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            case .failure:
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .background(Circle().foregroundColor(.red))
                    }
                    //   }
                    Text(vm.postDetail?.createdUser.nickname ?? "닉네임 불러오는중...")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(vm.postDetail?.title ?? "제목 불러오는중...")
                        .font(.system(size: 18))
                    //  .fontWeight(.bold)
                    
                    Text(vm.postDetail?.createdDate ?? "Date")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    
                    Text(vm.postDetail?.content ?? "내용 불러오는중...")
                        .font(.body)
                        .padding(.top, 10)
                }
                
                LikeAndReplyView(vm: vm, postId: postId)
            }
            .padding(.horizontal)
            .onAppear {
                print("Loading post details for postId: \(postId)")
                vm.loadDetailPosts(postId: postId)
            }

            .toolbar {
                ToolbarItem {
                    Menu {
                        if isUserPost() {
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                                  
                            }
                        } else {
                            Button(role: .destructive) {
                                showAlert = true
                            } label: {
                                Label("신고", systemImage: "exclamationmark.circle")
                                
                            }
                        }
                    } label: {
                        Image("menu.icon")
                            .imageScale(.large)
                    }
                }
            }
            .alert("신고 확인", isPresented: $showAlert) {
                Button("확인", role: .destructive) {
                    showReportConfirmation = true
                    vm.reportPost(postId: postId)
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("이 게시물을 신고하시겠습니까?")
            }
            .alert("삭제 확인", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    showDeleteConfirmation = true
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("게시글을 삭제하시겠습니까?")
            }
            .alert("삭제 완료", isPresented: $showDeleteConfirmation) {
                Button("확인", role: .cancel) {
                 // vm.deletePost(postId: postId)
                    dismiss()
                }
            } message: {
                Text("게시글이 삭제되었습니다.")
            }

            
         
        }
    }

    private func isUserPost() -> Bool {
           guard let userIdString = UserDefaults.standard.string(forKey: "UserId"),
                 let userId = Int(userIdString),
                 let postUserId = vm.postDetail?.createdUser.id else {
               return false
           }
           return userId == postUserId
       }
    
    
}





struct AutoScroller2: View {
	@State private var selectedImageIndex: Int = 0
	
    var imageURLs: [URL]
	let size: CGFloat

    var body: some View {
        ZStack {
            TabView {
                ForEach(imageURLs, id: \.self) { url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
								.frame(width: size, height: size)
								.clipShape(RoundedRectangle(cornerRadius: 10))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
								.frame(width: size, height: size)
								.clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure:
                            Image(systemName: "empty.image")
                                .resizable()
                                .scaledToFill()
								.frame(width: size, height: size)
								.clipShape(RoundedRectangle(cornerRadius: 10))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
			
			HStack {
				ForEach(0..<imageURLs.count, id: \.self) { index in
					Capsule()
						.fill(Color.white.opacity(selectedImageIndex == index ? 1 : 0.33))
						.frame(width: 10, height: 10)
						.onTapGesture {
							selectedImageIndex = index
						}
				}
			}
			.offset(y: size/2 - 20)
        }
    }
}
//
struct LikeAndReplyView: View {
    @ObservedObject var vm: CommunityViewModel
    let postId: Int

    var body: some View {
        HStack {
            Button {
                vm.isLiked.toggle()  // 좋아요 상태 토글
                if vm.isLiked {
                    vm.likeCounts += 1
                    vm.likePost(postId: postId)
                    print("postid\(postId)")
                } else {
                    vm.likeCounts -= 1
                    vm.dislikePost(postId: postId)
                    print("postid\(postId)")
                }
            } label: {
                HStack {
                    Text("좋아요")
						.tint(.black)
                    Image(systemName: vm.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(vm.isLiked ? .red : .black)
                }
            }
            Text("\(vm.likeCounts)")

            NavigationLink(destination: PostReplyView(vm: vm,postId:postId)) {
                HStack {
                    Text("댓글")
						.tint(.black)
                    Image(systemName: "bubble")
						.tint(.black)
                }
            }
            Text("\(vm.commentCounts)")
        }
    }
}





//            .toolbar {
//                            ToolbarItem {
//                                Menu {
//                                    Button(role: .destructive) {
//                                        showAlert = true
//                                    } label: {
//                                        Label("신고", systemImage: "exclamationmark.circle")
//                                            .frame(width: 22, height: 30)
//                                    }
//                                   // if isUserPost() {
//                                        Button {
//                                            showDeleteAlert = true
//                                        } label: {
//                                            Label("삭제", systemImage: "trash")
//                                                .frame(width: 22, height: 30)
//                                                .foregroundColor(.black)
//                                        }
//                                //    }
//                                } label: {
//                                    Image("menu.icon")
//                                        .frame(width: 22, height: 30)
//                                }
//                            }
//                        }
//                        .alert("신고 확인", isPresented: $showAlert) {
//                            Button("확인", role: .destructive) {
//                                showReportConfirmation = true
//                                vm.reportPost(postId: self.postId)
//                                print("신고 postId\(postId)")
//                            }
//                            Button("취소", role: .cancel) {}
//                        } message: {
//                            Text("이 게시물을 신고하시겠습니까?")
//                        }
//                        .alert("신고 완료", isPresented: $showReportConfirmation) {
//                            Button("확인", role: .cancel) {
//                                dismiss()
//                            }
//                        } message: {
//                            Text("신고가 처리되었습니다.")
//                        }
//                        .alert("삭제 확인", isPresented: $showDeleteAlert) {
//                            Button("확인", role: .destructive) {
//                                showDeleteConfirmation = true
//                            }
//                            Button("취소", role: .cancel) {}
//                        } message: {
//                            Text("게시글을 삭제하시면 다시 복구하실 수 없습니다. 그래도 삭제하시겠습니까?")
//                        }
//                        .alert("삭제 완료", isPresented: $showDeleteConfirmation) {
//                            Button("확인", role: .cancel) {
//                                vm.deletePost(postId: self.postId)
//                                dismiss()
//                            }
//                        } message: {
//                            Text("게시글이 삭제되었습니다.")
//                        }
//                    }
//                }


//    .toolbar {
//        ToolbarItem {
//            Menu {
//                Button(role: .destructive) {
//                    showAlert = true
//                } label: {
//                    Label("신고", systemImage: "exclamationmark.circle")
//                }
//            } label: {
//                Image("menu.icon")
//                    .imageScale(.large)
//            }
//        }
//    }
//    .alert("신고 확인", isPresented: $showAlert) {
//        Button("확인", role: .destructive) {
//            showReportConfirmation = true
//            vm.reportPost(postId: self.postId)
//            print("신고 postId \(postId)")
//        }
//        Button("취소", role: .cancel) {}
//    } message: {
//        Text("이 게시물을 신고하시겠습니까?")
//    }
//    .alert("신고 완료", isPresented: $showReportConfirmation) {
//        Button("확인", role: .cancel) {
//            dismiss()
//        }
//    } message: {
//        Text("신고가 처리되었습니다.")
//    }
