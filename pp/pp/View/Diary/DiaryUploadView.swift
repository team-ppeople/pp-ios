//
//  DiaryUploadView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI
import PhotosUI

struct DiaryUploadView: View {
    @ObservedObject var vm: DiaryViewModel = DiaryViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let maxPhotosToSelect = 10

    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .top, spacing: 30) {
                    ScrollView(.horizontal) {
                        HStack(alignment: .center, spacing: 10) {
                            PhotosPicker(
                                selection: $vm.selectedPhotos,
                                maxSelectionCount: maxPhotosToSelect,
                                selectionBehavior: .ordered,
                                matching: .images
                            ) {
                                Image(systemName: "camera.fill")
                                    .tint(.sub)
                            }
                            
                            .onChange(of: vm.selectedPhotos) { _ in
                                Task {
                                    vm.convertDataToImage()
                                }
                            }
                            .frame(width: 65, height: 65)
                            .cornerRadius(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.sub, lineWidth: 1))

                            LazyHGrid(rows: [GridItem(.fixed(65))]) {
                                ForEach(0..<vm.images2.count, id: \.self) { index in
                                    NavigationLink(destination: ImageDetailView(image: vm.images2[index])) {
                                        Image(uiImage: vm.images2[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 91, height: 65)
                                            .cornerRadius(5)
                                            .background(.sub)
                                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                                    }
                                }
                            }
                        }
                        .frame(height: 100)
                        .padding(.leading, 20)
                    }
                    .background(Color.clear)
                }
               
                Spacer()

                VStack {
                    TextField("Title", text: $vm.title)
                    TextField("Body", text: $vm.contents)
                    Button("작성 완료", action: {
                        vm.createDiaryPost()
                        vm.clearStates()
                        presentationMode.wrappedValue.dismiss()
                        
                    })
                    .frame(width: 120, height: 40)
                    .background(Color.sub)
                    .cornerRadius(5)
                }
                Spacer()
            }
          
        }
    }
}

// Preview
struct DiaryUploadView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryUploadView()
    }
}
