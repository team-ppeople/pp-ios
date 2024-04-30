//
//  DiaryUploadView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//
import SwiftUI
import PhotosUI

struct DiaryUploadView: View {
    @ObservedObject var vm: DiaryViewModel
	@State private var contents: String = ""
	@Environment(\.dismiss) private var dismiss
	
    let maxPhotosToSelect = 10

    var body: some View {

        NavigationView {
            VStack {
                PhotoPickerView(selectedPhotos: $vm.selectedPhotos, maxPhotosToSelect: maxPhotosToSelect, vm: vm)
                
                TextInputView(title: $vm.title, contents: $vm.contents)
                    .padding(.top, 10)

                HStack {
                    Spacer()
                    Button("작성 완료") {
                        vm.createDiaryPost()
                        vm.clearStates()
						dismiss()
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
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

    }
}

struct PhotoPickerView: View {
    @Binding var selectedPhotos: [PhotosPickerItem]
    var maxPhotosToSelect: Int
    @ObservedObject var vm: DiaryViewModel

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
                        vm.convertDataToImage()
                    }
                }
                .frame(width: 65, height: 65)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(.sub, lineWidth: 1))
                
                LazyHGrid(rows: [GridItem(.fixed(65))]) {
					ForEach(0..<vm.uiImages.count, id: \.self) { index in
						NavigationLink(destination: ImageCropView(vm: vm, index: index)) {
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
