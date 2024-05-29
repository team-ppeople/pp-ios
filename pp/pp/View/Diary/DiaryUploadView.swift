//
//  DiaryUploadView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI
import PhotosUI
import Mantis

struct DiaryUploadView: View {
    @ObservedObject var vm: DiaryViewModel
	@State private var contents: String = ""
	@State private var selectedIndex: Int = 0
	@State private var isShownSheet = false
	@Environment(\.dismiss) private var dismiss
	
    let maxPhotosToSelect = 10

    var body: some View {
        NavigationView {
            VStack {
				PhotoPickerView<DiaryViewModel>(vm: vm, selectedPhotos: $vm.selectedPhotos, selectedIndex: $selectedIndex, isShownSheet: $isShownSheet, maxPhotosToSelect: maxPhotosToSelect,editingMode: false)
                
                TextInputView(title: $vm.title, contents: $vm.contents)
                    .padding(.top, 10)

                HStack {
                    Spacer()
                    Button("작성 완료") {
                        print("photoDiary\($vm.uiImages)")
						vm.convertImageToData {
							vm.createDiaryPost()
							vm.clearStates()
							dismiss()
						}
                    }
					.tint(.white)
                    .frame(width: 120, height: 40)
					.background(.accent)
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
        }
        .navigationBarTitle("업로드", displayMode: .inline)
		.sheet(isPresented: $isShownSheet, content: {
			ImageCropper(image: $vm.uiImages[selectedIndex])
		})
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
	DiaryUploadView(vm: DiaryViewModel())
}
