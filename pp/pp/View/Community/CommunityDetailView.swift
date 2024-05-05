//
//  CommunityDetailView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

//struct CommunityDetailView: View {
//    @ObservedObject var vm: DiaryViewModel
//    @Environment(\.dismiss) private var dismiss
//    
//    let communityPost: DiaryPost
//    let images: [Image]
//    
//    var body: some View {
//        VStack {
//            if images.count != 0 {
//                AutoScroller(images: images)
//                    .frame(height: 258)
//            }
//        
//            Text(diaryPost.title ?? "")
//                .font(.system(size: 18))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.top, 25)
//            
//            Text(Utils.toString(diaryPost.date))
//                .font(.system(size: 12))
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            Text(diaryPost.contents ?? "")
//                .font(.system(size: 15))
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.top, 20)
//            
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 25)
//        .toolbar {
//            ToolbarItem {
//                Menu {
//                    Button("신고") {
//                        vm.deleteDiaryPost(diaryPost)
//                        dismiss()
//                    }
//                } label: {
//                    Image("menu.icon")
//                        .frame(width: 22, height: 30)
//                }
//            }
//        }
//        .toolbar(.hidden, for: .tabBar)
//    }
//}
//#Preview {
//    CommunityDetailView()
//}
