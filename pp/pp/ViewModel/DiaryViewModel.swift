//
//  DiaryViewModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation
import PhotosUI
import SwiftUI

class DiaryViewModel: ObservableObject {
	@Published var diaryPosts: [DiaryPost] = []
    @Published var images2: [UIImage] = []
    @Published var selectedPhotos:[PhotosPickerItem] = []

   
  
	let dataService = PersistenceController.shared

	@Published var title: String = ""
	@Published var contents: String = ""
	@Published var images: [Data] = []
    
	
	init() {
		getDiaryPosts()
	}

    @MainActor
    func convertDataToImage() {
        images2.removeAll()
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        // JPEG 형식으로 이미지 데이터를 압축합니다. 품질 인자로 0.5를 사용
                        if let image = UIImage(data: imageData),
                           let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                            images.append(compressedImageData)
                            
                            if let compressedImage = UIImage(data: compressedImageData) {
                                images2.append(compressedImage)
                            }
                        }
                    }
                }
            }
        }
 
        selectedPhotos.removeAll()
    }

	
    
	func getDiaryPosts() {
		self.diaryPosts = dataService.read()
	}
	
	func createDiaryPost() {
		dataService.create(title: title, contents: contents, images: images)
		getDiaryPosts()
       
        print("diary object is \(diaryPosts)")
	}
	
	func deleteDiaryPost(_ diaryPost: DiaryPost) {
		dataService.delete(diaryPost)
		getDiaryPosts()
	}
	
	func clearStates() {
		title = ""
		contents = ""
		images = []
        images2 = []
	}
}
