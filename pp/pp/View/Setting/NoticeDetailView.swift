//
//  NoticeDetailView.swift
//  pp
//
//  Created by 임재현 on 5/31/24.
//

import SwiftUI

struct NoticeDetailView: View {
    let notice: Notice

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(notice.title)
                    .font(.title)
                    .bold()
                    .padding(.bottom, 8)
                Text(notice.createDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
                Divider()
                Text(notice.content)
                    .font(.body)
                    .padding(.top, 16)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("공지사항")
        .navigationBarTitleDisplayMode(.inline)
    }
}
