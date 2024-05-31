//
//  NoticeView.swift
//  pp
//
//  Created by 임재현 on 5/31/24.
//

import SwiftUI

struct Notice: Identifiable, Hashable {
    let id: Int
    let title: String
    let content: String
    let createDate: String
}





struct NoticeView: View {
    let notices = [
           Notice(id: 41, title: "[41] PP 서비스를 사용해주셔서 감사합니다.", content: "더 좋은 서비스로 보답하겠습니다.", createDate: "2024.04.25"),
           Notice(id: 40, title: "[40] PP 서비스를 사용해주셔서 감사합니다.", content: "더 좋은 서비스로 보답하겠습니다.", createDate: "2024.04.25"),
          
       ]


    var body: some View {
        List {
                   ForEach(notices) { notice in
                       NavigationLink(destination: NoticeDetailView(notice: notice)) {
                           NoticeCellView(notice: notice)
                       }
                   }
               }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .horizontal)

        .navigationTitle("공지사항")
    }
}




struct NoticeCellView: View {
    let notice: Notice

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(notice.title).font(.headline)
            Text(notice.createDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
