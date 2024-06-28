//
//  PostReplyView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

//
import SwiftUI

struct PostReplyView: View {
    
    @ObservedObject var vm: CommunityViewModel
    let postId:Int
    
    @State private var showAlert = false
    @State private var textEditorHeight: CGFloat = 34
    @State private var maxEditorHeight: CGFloat = 170
    @State private var keyboardHeight: CGFloat = 0
    @State private var isEditing = false
    @State private var reportCommentId: Int?
    @State private var showReportConfirmation = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    
                   List {
                        ForEach($vm.comments) { $comments in

                            ReplyCellView(id: comments.id, comments: comments.content, user: comments.createdUser, createDate: comments.createDate, vm: vm)
                                .padding(.leading, -16)

                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        reportCommentId = comments.id
                                        showAlert = true
                                    } label: {
                                        Label("신고", systemImage: "exclamationmark.circle.fill")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .ignoresSafeArea(edges: .horizontal)

                    Divider()

                    HStack(spacing: 10) {
                        ZStack {
                         RoundedRectangle(cornerRadius: 16)
                           // Capsule()
                                .strokeBorder(Color.secondary, lineWidth: 1)
                                .background(Color.white)
                                .frame(height: max(50, textEditorHeight))

                            HStack {
                                DynamicHeightTextEditor(text: $vm.newComment, height: $textEditorHeight, maxEditorHeight: maxEditorHeight)
                                    .frame(height: min(textEditorHeight, maxEditorHeight))

                                Spacer()

                                Button(action: {
                                    hideKeyboard()
                                    addComment()
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                }
                                .disabled(vm.newComment.isEmpty)
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                if isEditing {
                    VStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                hideKeyboard()
                            }
                        Spacer()
                            .frame(height: textEditorHeight + 16)
                    }
                }
            }

            .task {
                           vm.loadComments(postId: self.postId, lastId: nil)
                       }
            .onAppear {
                vm.newComment = ""
                setupKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
                vm.newComment = ""
            }
            
            
            .alert("이 댓글을 신고하시겠습니까?", isPresented: $showAlert) {
                Button("예", role: .destructive) {
                    if let id = reportCommentId {
                        vm.reportComment(commentId: id) { result in
                            switch result {
                            case .success():
                                showReportConfirmation = true
                            case .failure(let error):
                               
                                
                                
                                print("에러가 발생했단다\(error)")
                               
                                
                                errorMessage = error.detail
                                
                               
                                showErrorAlert = true
                            }
                        }
                    }
                }
                Button("아니요", role: .cancel) {}
            } message: {
                Text("신고하면 관리자 검토 후 조치됩니다.")
            }
            .alert("신고가 완료되었습니다.", isPresented: $showReportConfirmation) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("관리자 검토가 완료되면 적절한 조치가 이루어집니다.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
               
                
                
                Text(errorMessage ?? "An unknown error occurred")
            }


            .navigationTitle("댓글")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isEditing = false
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
                isEditing = true
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) {
            _ in keyboardHeight = 0
            isEditing = false
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    func addComment() {
        vm.submitComments(postId: postId, content: vm.newComment)
        vm.newComment = ""
    }
}


struct ReplyCellView: View {
    
    let id: Int
    let comments: String
    let user: CreatedUser
    let createDate:String

    @ObservedObject var vm: CommunityViewModel
    
    @State var showFullText: Bool = false
    @State private var isActive = false  // NavigationLink 활성화를 위한 상태 변수


    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // NavigationLink와 함께 클릭 가능한 프로필 이미지
            NavigationLink(destination: UserProfileView(vm: vm, userId: user.id), isActive: $isActive) {
                

                EmptyView()
            }
            
        
            
            .hidden()
            .frame(width: 0, height: 0)
            
            Button(action: {
                self.isActive = true  // 버튼 클릭 시 NavigationLink 활성화
            }) {
                profileImageView(url: user.profileImageURL)
            }
            .buttonStyle(PlainButtonStyle())  // 버튼 스타일 제거하여 이미지만 표시

            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    Text(user.nickname)
                        .font(.headline)
                        .foregroundColor(Color.primary)
                    Text(createDate)
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                        .padding(.leading, 8)
                    
                }
                
                
                Text(comments)
                    .lineLimit(showFullText ? nil : 3)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if comments.count > 100 {
                    Button(showFullText ? "접기" : "더보기") {
                        showFullText.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.leading, 0)  // 왼쪽 패딩을 0으로 설정하여 더 왼쪽으로 밀착
    }

    // 프로필 이미지를 로딩하는 뷰
    @ViewBuilder
    private func profileImageView(url: URL?) -> some View {
        if let url = url {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable()
                } else if phase.error != nil {
					ProgressView()
						.frame(width: 35, height: 35)
                } else {
					Image(systemName: "person.fill")
						.resizable()
						.scaledToFill()
						.frame(width: 35, height: 35)
						.clipShape(Circle())
						.background(Circle().foregroundColor(.sub))
                }
            }
            .scaledToFill()
            .frame(width: 35, height: 35)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
				.background(Circle().foregroundColor(.sub))
        }
    }
}


struct DynamicHeightTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    var maxEditorHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        DynamicHeightTextEditor.recalculateHeight(view: uiView, result: $height, maxEditorHeight: maxEditorHeight)
        uiView.isScrollEnabled = height >= maxEditorHeight
    }

    static func recalculateHeight(view: UIView, result: Binding<CGFloat>, maxEditorHeight: CGFloat) {
        let size = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        DispatchQueue.main.async {
            result.wrappedValue = min(size.height, maxEditorHeight)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DynamicHeightTextEditor

        init(parent: DynamicHeightTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            DynamicHeightTextEditor.recalculateHeight(view: textView, result: parent.$height, maxEditorHeight: parent.maxEditorHeight)
        }
    }
}
