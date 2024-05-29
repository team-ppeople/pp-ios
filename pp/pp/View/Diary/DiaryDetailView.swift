//
//  DiaryDetailView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct DiaryDetailView: View {
	@ObservedObject var vm: DiaryViewModel
	@Environment(\.dismiss) private var dismiss
	
	let diaryPost: DiaryPost
	let images: [Image]
    
	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				if images.count != 0 {
					AutoScroller(images: images, size: abs(geometry.size.width - 32))
						.frame(width: abs(geometry.size.width - 32), height: abs(geometry.size.width - 32))
				}
				
				Text(diaryPost.title ?? "")
					.font(.system(size: 18))
					.padding(.top, 25)
				
				Text(Utils.toString(diaryPost.date))
					.font(.system(size: 12))
				
				Text(diaryPost.contents ?? "")
					.font(.system(size: 15))
					.padding(.top, 20)
				
				Spacer()
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 25)
			.toolbar {
				ToolbarItem {
					Menu {
						Button("삭제") {
							vm.deleteDiaryPost(diaryPost)
							dismiss()
						}
					} label: {
						Image("menu.icon")
							.frame(width: 22, height: 30)
					}
				}
			}
		}
	}
}

struct AutoScroller: View {
	@State private var selectedImageIndex: Int = 0
	
    var images: [Image]
    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
	let size: CGFloat

    var body: some View {
        ZStack {
            TabView(selection: $selectedImageIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    ZStack(alignment: .topLeading) {
						images[index]
							.resizable()
							.scaledToFill()
							.frame(width: size, height: size)
							.clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
			
            HStack {
                ForEach(0..<images.count, id: \.self) { index in
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
        .onReceive(timer) { _ in
            withAnimation(.default) {
                selectedImageIndex = (selectedImageIndex + 1) % images.count
            }
        }
    }
}
