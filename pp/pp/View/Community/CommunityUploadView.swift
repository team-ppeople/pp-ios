//
//  CommunityUploadView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct CommunityUploadView: View {
    @ObservedObject var vm: CommunityViewModel
    @State private var contents: String = ""
    @State private var selectedIndex: Int = 0
    @State private var isShownSheet = false
    @State private var showAlert = false
    @State private var showUnsavedChangesAlert = false
    @Environment(\.dismiss) private var dismiss
    
    let maxPhotosToSelect = 10

    var body: some View {
        NavigationView {
            VStack {
                PhotoPickerView<CommunityViewModel>(vm: vm, selectedPhotos: $vm.selectedPhotos, selectedIndex: $selectedIndex, isShownSheet: $isShownSheet, maxPhotosToSelect: maxPhotosToSelect, editingMode: false)
                TextInputView(title: $vm.title, contents: $vm.contents)
                    .padding(.top, 10)

                HStack {
                    Spacer()
                    Button("작성 완료") {
                        if !isValidInput(vm.title) || !isValidInput(vm.contents) || vm.uiImages.isEmpty {
                            showAlert = true
                        } else {
                            vm.writePost(title: vm.title, content: vm.contents)
                            dismiss()
                            vm.reset()
                        }
                    }
                    .tint(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.accentColor)
                    .cornerRadius(5)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                Spacer()
            }
            .onTapGesture {
                hideKeyboard()
            }
            .padding(.top, 24)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("입력 오류"),
                    message: Text("이미지, 제목 및 내용을 모두 입력해 주세요."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
        .navigationBarTitle("업로드", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // 기본 네비게이션 뒤로가기 버튼 숨기기
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if !vm.title.isEmpty || !vm.contents.isEmpty || !vm.uiImages.isEmpty {
                        showUnsavedChangesAlert = true
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                    Text("뒤로")
                }
            }
        }
        .alert(isPresented: $showUnsavedChangesAlert) {
            Alert(
                title: Text("경고"),
                message: Text("현재 작성 중인 내용이 전부 사라집니다. 계속하시겠습니까?"),
                primaryButton: .destructive(Text("확인")) {
                    vm.reset()
                    dismiss()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
        .sheet(isPresented: $isShownSheet) {
            ImageCropper(image: $vm.uiImages[selectedIndex])
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func isValidInput(_ input: String) -> Bool {
        // 유효성 검사 - 공백문자만 있는지, Html 태그 방지, 최소한 하나의 공백 아닌 문자 포함해야 함
        let pattern = "^(?!\\s*$)(?!.*<[^>]+>).+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex?.firstMatch(in: input, options: [], range: range) != nil
    }
}
