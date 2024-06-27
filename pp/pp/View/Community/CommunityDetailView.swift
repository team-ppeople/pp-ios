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
	@State private var showReportConfirmation = false  // 신고 처리 확인용 Alert 표시
	@State private var showDeleteAlert = false
	@State private var showDeleteConfirmation = false
	@State private var isUserProfileActive = false  // NavigationLink 활성화를 위한 상태 변수
	
	var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(alignment: .leading) {
				if let imageUrls = vm.postDetail?.imageUrls, !imageUrls.isEmpty {
					AutoScroller2(imageURLs: imageUrls, size: UIScreen.main.bounds.width - 32)
						.frame(height: UIScreen.main.bounds.width - 32)
						.padding(.top, 20)
				}
				
				HStack {
					if let profileImageUrl = vm.postDetail?.createdUser.profileImageURL {
						NavigationLink(destination: UserProfileView(vm: vm, userId: vm.postDetail?.createdUser.id), isActive: $isUserProfileActive) {
							EmptyView()
						}
						.hidden()
						
						Button(action: {
							isUserProfileActive = true  // 버튼 클릭 시 NavigationLink 활성화
						}) {
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
						}
						.buttonStyle(PlainButtonStyle())  // 버튼 스타일 제거하여 이미지만 표시
					} else {
						Image(systemName: "person.fill")
							.resizable()
							.scaledToFill()
							.frame(width: 58, height: 58)
							.clipShape(Circle())
							.background(Circle().foregroundColor(.sub))
					}
					
					Text(vm.postDetail?.createdUser.nickname ?? "")
						.font(.title2)
						.foregroundColor(.primary)
					
					Spacer()
				}
				.padding(.top, 20)
				.frame(maxWidth: .infinity)
				
				Text(vm.postDetail?.title ?? "")
					.font(.system(size: 18))
					.padding(.top, 8)
				
				Text(vm.postDetail?.createdDate ?? "")
					.font(.system(size: 15))
					.foregroundColor(.secondary)
					.padding(.top, 3)
				
				Text(vm.postDetail?.content ?? "")
					.font(.body)
					.padding(.vertical, 5)
				
				LikeAndReplyView(vm: vm, postId: postId)
					.padding(.vertical, 15)
			}
			.frame(maxWidth: .infinity)
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
				vm.reportPost(postId: self.postId)
				print("신고 postId\(postId)")
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
			Text("게시글을 삭제하시면 다시 복구하실 수 없습니다. 그래도 삭제하시겠습니까?")
		}
		.alert("삭제 완료", isPresented: $showDeleteConfirmation) {
			Button("확인", role: .cancel) {
				vm.deletePost(postId: self.postId)
				dismiss()
			}
		} message: {
			Text("게시글이 삭제되었습니다.")
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
	var imageURLs: [URL]
	let size: CGFloat
	
	var body: some View {
		ZStack {
			TabView {
				ForEach(imageURLs, id: \.self) { url in
					AsyncImage(url: url) { phase in
						switch phase {
						case .empty:
							Image(systemName: "empty.image")
								.resizable()
								.scaledToFill()
								.frame(width: size, height: size)
								.clipShape(RoundedRectangle(cornerRadius: 10))
						case .success(let image):
							image
								.resizable()
								.scaledToFill()
								.frame(width: size, height: size)
								.clipShape(RoundedRectangle(cornerRadius: 10))
						case .failure:
							ProgressView()
								.frame(width: size, height: size)
								.clipShape(RoundedRectangle(cornerRadius: 10))
						@unknown default:
							EmptyView()
						}
					}
				}
			}
			.tabViewStyle(.page)
			.ignoresSafeArea()
		}
	}
}
	
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
