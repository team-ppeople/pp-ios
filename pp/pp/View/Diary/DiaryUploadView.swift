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
				PhotoPickerView(vm: vm, selectedPhotos: $vm.selectedPhotos, selectedIndex: $selectedIndex, isShownSheet: $isShownSheet, maxPhotosToSelect: maxPhotosToSelect)
                
                TextInputView(title: $vm.title, contents: $vm.contents)
                    .padding(.top, 10)

                HStack {
                    Spacer()
                    Button("작성 완료") {
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

struct PhotoPickerView: View {
	@ObservedObject var vm: DiaryViewModel
    @Binding var selectedPhotos: [PhotosPickerItem]
	@Binding var selectedIndex: Int
	@Binding var isShownSheet: Bool

    var maxPhotosToSelect: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: maxPhotosToSelect,
                    selectionBehavior: .ordered,
                    matching: .images
                ) {
                    Image(systemName: "camera.fill").tint(.sub)
                }
                .onChange(of: selectedPhotos) { _ in
                    Task {
                        vm.addSelectedPhotos()
                    }
                }
                .frame(width: 65, height: 65)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(.sub, lineWidth: 1))
                
                LazyHGrid(rows: [GridItem(.fixed(65))]) {
					ForEach(0..<vm.uiImages.count, id: \.self) { index in
						Button(action: {
							isShownSheet = true
							selectedIndex = index
						}) {
							Image(uiImage: vm.uiImages[index])
								.resizable()
								.scaledToFit()
								.frame(width: 91, height: 65)
								.background(Color("#F3F3F3"))
								.cornerRadius(5)
						}
						
					}
				}
			}
            .frame(height: 65)
            .padding(.leading, 20)
            .padding(.vertical, 5)
        }
        .frame(height: 70)
    }
}

struct TextInputView: View {
    @Binding var title: String
    @Binding var contents: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("제목")
				.font(.system(size: 16))
				.fontWeight(.medium)
            TextField("제목", text: $title)
                .padding(.vertical, 8)
                .background(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.sub, lineWidth: 0.5)
                )

            Text("내용")
				.font(.system(size: 16))
				.fontWeight(.medium)
				.padding(.top, 30)
            TextEditor(text: $contents)
                .frame(height: 280)
                .padding(.vertical, 8)
                .background(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.sub, lineWidth: 0.5)
                )
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
}

#Preview {
	DiaryUploadView(vm: DiaryViewModel())
}
