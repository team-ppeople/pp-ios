//
//  PhotoPickerView.swift
//  pp
//
//  Created by 김지현 on 2024/05/23.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView<ViewModel: PhotoPickerViewModel>: View {
    @ObservedObject var vm: ViewModel
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var selectedIndex: Int
    @Binding var isShownSheet: Bool
    
    var tempProfileImage: Binding<UIImage?>? = nil
    var maxPhotosToSelect: Int
    var editingMode: Bool
    @State private var showAlert = false

    var body: some View {
        if editingMode {
            HStack(alignment: .center) {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: maxPhotosToSelect,
                    matching: .images
                ) {
                    // 분기 처리하여 각 뷰 모델의 프로필 이미지 처리
                    if let tempProfileImage = tempProfileImage?.wrappedValue {
                        Image(uiImage: tempProfileImage)
                            .resizable()
                            .scaledToFill()
							.frame(width: 70, height: 70)
							.clipShape(Circle())
							.background(Circle().foregroundColor(.sub))
                    } else if let profileImageUrl = getProfileImageUrl(from: vm) {
                        AsyncImage(url: profileImageUrl) { phase in
                            switch phase {
                            case .empty:
								Image(systemName: "person.fill")
									.resizable()
									.scaledToFill()
									.frame(width: 70, height: 70)
									.clipShape(Circle())
									.background(Circle().foregroundColor(.sub))
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                            case .failure:
								ProgressView()
									.frame(width: 70, height: 70)
									.background(Circle().foregroundColor(.sub))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
						Image(systemName: "person.fill")
							.resizable()
							.scaledToFill()
							.frame(width: 70, height: 70)
							.clipShape(Circle())
							.background(Circle().foregroundColor(.sub))
                    }
                }
                .onChange(of: selectedPhotos) { _ in
                    if selectedPhotos.count > 1 {
                        showAlert = true
                        selectedPhotos.removeAll()
                    } else {
                        Task {
                            if let profileItem = selectedPhotos.first,
                               let data = try? await profileItem.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                tempProfileImage?.wrappedValue = image
                                vm.profileImage = image
                                vm.addSelectedProfile()
                                selectedPhotos.removeAll()
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 5)
            .frame(height: 70)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("경고"),
                    message: Text("프로필 사진은 한개만 선택할 수 있습니다."),
                    dismissButton: .default(Text("OK"))
                )
            }
        } else {
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
                                    .scaledToFill()
                                    .frame(width: 65, height: 65)
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

    // 프로필 이미지 URL 가져오기 함수
    private func getProfileImageUrl(from viewModel: ViewModel) -> URL? {
        if let userVM = viewModel as? UserViewModel {
            return userVM.profileImageUrl
        } else if let communityVM = viewModel as? CommunityViewModel {
            return communityVM.profileImageUrl
        }
        return nil
    }
}
