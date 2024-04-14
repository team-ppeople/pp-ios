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
            ZStack(alignment: .bottomTrailing) {
                if vm.diaryPosts.count == 0 {
                    Spacer()
                    Text("아직 저장된 일기가 없습니다.\n일기 쓰기 버튼을 눌러 새로 만드세요.")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                   
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 24) {
                                ForEach(vm.diaryPosts, id: \.self) { diaryPost in
                                    NavigationLink(destination: DiaryDetailView(diaryPost: diaryPost)) {
                                        VStack(alignment: .leading) {
                                            Utils.createImage(diaryPost.images?.first)
                                                .resizable()
                                                .frame(width: 171, height: 121)
                                            
                                            Text(diaryPost.title ?? "")
                                                .font(.system(size: 15))
                                                .bold()
                                                .foregroundColor(.black)
                                                .lineLimit(1)
                                                .multilineTextAlignment(.leading)
                                                .padding(.horizontal, 10)
                                                .padding(.top, 3)
                                            
                                            Text(diaryPost.contents ?? "")
                                                .font(.system(size: 12))
                                                .foregroundColor(.black)
                                                .lineLimit(1)
                                                .multilineTextAlignment(.leading)
                                                .padding(.horizontal, 10)
                                                .padding(.bottom, 5)
                                        }
                                        .background(RoundedRectangle(cornerRadius: 5).fill(.white))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 24)
                            .background(Color("#EBEBF4"))
                        }
                        .frame(height: geometry.size.height)
                    }
                    
                    
                    
                    
                    
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {} label: {
                        NavigationLink(destination: DiaryUploadView(vm: self.vm)) {
                            HStack {
                                Image(systemName: "pencil")
                                    .tint(.white)
                                    .font(.system(size: 26, weight: .bold))
                            }
                            .frame(width: 50, height: 50)
                        }
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
                    .background(.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .shadow(color: .gray, radius: 3, x: 1, y: 1)
                    .zIndex(1.0)
                }
                .padding(16)
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

//print("hi")

#Preview {
    DiaryView()
}
