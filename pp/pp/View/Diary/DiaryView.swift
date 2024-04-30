//
//  DiaryView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//
//

import SwiftUI

struct DiaryView: View {
    @ObservedObject var vm: DiaryViewModel = DiaryViewModel()

    var body: some View {
		
        NavigationStack {
            ZStack(alignment: .bottomTrailing) { 
				GeometryReader { geometry in
					VStack {
						if vm.diaryPosts.isEmpty {
							emptyStateView
						} else {
							diaryPostsGrid
						}
					}
					.toolbar {
						ToolbarItem {
							HStack {
								Text("나의 일기")
									.font(.system(size: 20))
									.bold()
									.padding(.leading, 16)
								Spacer()
							}
							.frame(width: geometry.size.width, height: 45)
							.background(.white)
						}
					}
				}
				
				floatingActionButton
					.padding(16)
            }
        }
    }

    private var emptyStateView: some View {
        Text("아직 저장된 일기가 없습니다.\n일기 쓰기 버튼을 눌러 새로 만드세요.")
            .multilineTextAlignment(.center)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.offset(y: -20)
			.background(Color("#EBEBF4"), ignoresSafeAreaEdges: .leading)
    }
    
    private var diaryPostsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 24) {
                ForEach(vm.diaryPosts, id: \.self) { diaryPost in
                    DiaryPostPreview(diaryPost: diaryPost)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .background(Color("#EBEBF4"))
            
        }
        .offset(y: -20)
    }
    
    private var floatingActionButton: some View {
        NavigationLink(destination: DiaryUploadView(vm: vm)) {
            Image(systemName: "pencil")
                .foregroundColor(.white)
                .font(.system(size: 26, weight: .bold))
                .frame(width: 50, height: 50)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(color: .gray, radius: 3, x: 1, y: 1)
        }
    }
}

#Preview {
	DiaryView(vm: DiaryViewModel())
}
