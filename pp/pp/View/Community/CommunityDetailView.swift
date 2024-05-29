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
	
	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				if let imageUrls = vm.postDetail?.imageUrls, !imageUrls.isEmpty {
					AutoScroller2(imageURLs: imageUrls, size: abs(geometry.size.width - 32))
						.frame(width: abs(geometry.size.width - 32), height: abs(geometry.size.width - 32))
				} else {
					ProgressView()
						.frame(width: abs(geometry.size.width - 32), height: abs(geometry.size.width - 32))
				}
				
				Text(vm.postDetail?.title ?? "title")
					.font(.system(size: 18))
					.padding(.top, 25)
				
				Text(vm.postDetail?.createdDate ?? "date")
					.font(.system(size: 12))
				
				Text(vm.postDetail?.content ?? "content")
					.font(.system(size: 15))
					.padding(.top, 20)
				
				LikeAndReplyView(vm: vm,postId:postId)
				Spacer()
			}
			.onAppear {
				print("Loading post details for postId: \(postId)")
				vm.loadDetailPosts(postId: postId)
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 25)
			
			.toolbar {
				ToolbarItem {
					Menu {
						Button(role: .destructive) {
							showAlert = true
						} label: {
							Label("신고", systemImage: "exclamationmark.circle")
								.frame(width: 22, height: 30)
						}
					} label: {
						Image("menu.icon")
							.frame(width: 22, height: 30)
					}
				}
			}
			.alert("신고 확인", isPresented: $showAlert) {
				Button("확인", role: .destructive) {
					showReportConfirmation = true
					
						// ToDo: - fetchPost에서 각 게시글 Id 받아와서 가지고 있다 신고할때 이 Id 값으로 신고
					vm.reportPost(postId: self.postId)
					print("신고 postId\(postId)")
				}
				Button("취소", role: .cancel) {}
			} message: {
				Text("이 게시물을 신고하시겠습니까?")
			}
			.alert("신고 완료", isPresented: $showReportConfirmation) {
				Button("확인", role: .cancel) {
					dismiss()
				}
			} message: {
				Text("신고가 처리되었습니다.")
			}
		}
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
