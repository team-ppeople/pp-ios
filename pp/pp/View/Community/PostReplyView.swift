//
//  PostReplyView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//


import SwiftUI

struct PostReplyView: View {
   
    @ObservedObject var vm: PostViewModel
    
    // sampleData -> 추후 PostDetails의 Comments로 대체
    let sampleComment: [SampleComments] = [ SampleComments(username: "111", comments: "안녕하세요 반가워요"),
                                            SampleComments(username: "222", comments: "ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ"),
                                            SampleComments(username: "333", comments: "하하하하하하"),
                                            SampleComments(username: "444", comments: "정말 재밌군요!!"),
                                            SampleComments(username: "555", comments: "Hello world!"),
                                            SampleComments(username: "666", comments: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nisl tincidunt eget nullam non. Quis hendrerit dolor magna eget est lorem ipsum dolor sit. Volutpat odio facilisis mauris sit amet massa. Commodo odio aenean sed adipiscing diam donec adipiscing tristique. Mi eget mauris pharetra et. Non tellus orci ac auctor augue. Elit at imperdiet dui accumsan sit. Ornare arcu dui vivamus arcu felis. Egestas integer eget aliquet nibh praesent. In hac habitasse platea dictumst quisque sagittis purus. Pulvinar elementum integer enim neque volutpat ac."),
                                            SampleComments(username: "777", comments: "swift ios apple")]
                                            
   
    @State private var showAlert = false // Alert를 표시할 상태 변수

    var body: some View {
        NavigationStack {
            List(sampleComment, id: \.self) { item in
                ReplyCellView(username: item.username, comments: item.comments)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            reportItem() // 신고 처리 함수 호출
                        } label: {
                            Label("신고", systemImage: "exclamationmark.circle.fill")
                           //Text("신고")
                        }
                    }
            }
            .alert("신고 완료", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("해당 댓글이 신고 처리되었습니다.")
            }
            .listStyle(.plain)
            .ignoresSafeArea(edges: .horizontal)
            .navigationTitle("댓글")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func reportItem() {
        // 실제 신고 로직을 구현하는 곳 -> reportComments 함수 실행
        print("신고 처리")
        //ToDo: - commentId 받아와서 신고할때 그 Id로 게시물 신고
   //     vm.reportComment(commentId: <#T##Int#>)
        showAlert = true // 신고 완료 후 Alert를 표시
    }
}
struct ReplyCellView: View {
    let username: String
    let comments: String
    
    @State private var showFullText = false  // 댓글을 전체 보기 상태 관리

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image("kakao.login.icon")
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
                .background(Circle().fill(Color.red))
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(username)").font(.headline)
                Text("\(comments)")
                    .lineLimit(showFullText ? nil : 3)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if comments.count > 100 {  // 길이에 따라 더보기/접기 버튼 표시 조건
                    Button(showFullText ? "접기" : "더보기") {
                        showFullText.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .trailing) // 버튼을 오른쪽에 배치
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}


struct SampleComments:Hashable {
    let username:String
    let comments:String
}

