//
//  PostReplyView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

//
import SwiftUI

struct PostReplyView: View {
    
    @ObservedObject var vm: PostViewModel
    let postId:Int
    
   // @State private var newComment = ""
    @State private var showAlert = false
    @State private var textEditorHeight: CGFloat = 34
    @State private var maxEditorHeight: CGFloat = 170
    @State private var keyboardHeight: CGFloat = 0
    @State private var isEditing = false
   
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        ForEach($vm.comments) { $comments in
                            ReplyCellView(id: comments.id, comments: comments.content)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        reportItem()
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

                    HStack {
                        ZStack(alignment: .trailing) {
                            DynamicHeightTextEditor(text: $vm.newComment, height: $textEditorHeight, maxEditorHeight: maxEditorHeight)
                                .frame(height: min(textEditorHeight, maxEditorHeight))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .onTapGesture {
                                    isEditing = true
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary, lineWidth: 1)
                                )
                                .padding(.trailing, 34)

                            if vm.newComment.isEmpty {
                                Text("댓글 달기...")
                                    .foregroundColor(Color.secondary.opacity(0.5))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button(action: {
                                hideKeyboard()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    addComment()
                                }
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding(.trailing, 0)
                            }
                            .disabled(vm.newComment.isEmpty)
                            .padding(.leading, 32)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .background(Color.white.opacity(0.001))
                }

                if isEditing {
                    VStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                hideKeyboard()
                            }
                        Spacer()
                            .frame(height: textEditorHeight + 16) // TextEditor 높이에 맞춰 배경 높이 조정
                    }
                }
            }
            .task {
                vm.loadComments(postId: self.postId, limit: 20, lastId: nil)
            }
            .onAppear {
                setupKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
            .alert("신고 완료", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("해당 댓글이 신고 처리되었습니다.")
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
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
            isEditing = false
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func adjustTextEditorHeight() {
        let size = CGSize(width: UIScreen.main.bounds.width - 70, height: .infinity)
        let estimatedHeight = vm.newComment.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 17)],
            context: nil
        ).height
        textEditorHeight = max(34, min(estimatedHeight + 16, maxEditorHeight))
    }

    func addComment() {
        print("Adding comment: \(vm.newComment)")
       
        textEditorHeight = 34 // 댓글 추가 후 높이 초기화
        vm.submitComments(postId: postId, content: vm.newComment)
        vm.newComment = "" // 댓글을 추가한 후 입력 필드 초기화
    }

    func reportItem() {
        print("신고 처리")
        showAlert = true // 신고 완료 후 Alert를 표시
    }
}


struct ReplyCellView: View {
    
    let id:Int
    let comments: String
    @State var showFullText: Bool = false  // 댓글을 전체 보기 상태 관리

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
                Text("\(id)").font(.headline)
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
