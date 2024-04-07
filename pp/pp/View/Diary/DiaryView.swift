//
//  DiaryView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI
import Kingfisher

struct DiaryView: View {
	@ObservedObject var vm: DiaryViewModel = DiaryViewModel()
	
	var body: some View {
		NavigationStack {
			VStack {
				Spacer()
				
				if vm.diaryPosts.count == 0 {
					Text("아직 저장된 일기가 없습니다.\n일기 쓰기 버튼을 눌러 새로 만드세요.")
						.multilineTextAlignment(.center)
				} else {
					List {
						ForEach(vm.diaryPosts, id: \.self) { diaryPost in
							NavigationLink(destination: DiaryDetailView()) {
								HStack {
									VStack(alignment: .leading) {
										Text(diaryPost.title ?? "")
											.lineLimit(1)
											.bold()
										
										Text(diaryPost.contents ?? "")
											.lineLimit(1)
									}
								}
							}
						}
					}
				}
				
				Spacer()
				
				HStack {
					Spacer()
					
					Button {
						print("UploadView로 이동")
					} label: {
						NavigationLink(destination: DiaryUploadView(vm: self.vm)) {
							HStack {
								Image(systemName: "pencil")
									.tint(.white)
							}
							.frame(width: 40, height: 40)
						}
					}
					.background(.accent)
					.cornerRadius(40)
					.padding(16)
					.zIndex(1.0)
				}
			}
			.toolbar {
				ToolbarItem(placement: .navigation) {
					Text("나의 일기")
						.font(.system(size: 20))
						.bold()
				}
			}
		}
	}
}

#Preview {
    DiaryView()
}
