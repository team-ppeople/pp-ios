//
//  NoticeView.swift
//  pp
//
//  Created by 임재현 on 5/31/24.
//

import SwiftUI


struct NoticeView: View {
   
    @ObservedObject var vm: UserViewModel 


    var body: some View {
        List {
            ForEach(vm.notices,id: \.self) { notice in
                       NavigationLink(destination: NoticeDetailView(notice: notice)) {
                           NoticeCellView(notice: notice)
                       }
                   }
               }
        .task {
            vm.fetchNotices(lastId: nil)
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
