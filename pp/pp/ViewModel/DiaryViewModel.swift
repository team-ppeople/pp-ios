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
    @Published var uiImages: [UIImage] = []
    @Published var selectedPhotos: [PhotosPickerItem] = []

	let persistence = PersistenceController.shared

	@Published var title: String = ""
	@Published var contents: String = ""
	@Published var imagesData: [Data] = []

	init() {
		getDiaryPosts()
	}

    @MainActor
    func addSelectedPhotos() {
        uiImages.removeAll()
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
						if let image = UIImage(data: imageData) {
							uiImages.append(image)
                        }
                    }
                }
            }
        }
 
        selectedPhotos.removeAll()
    }
	
	@MainActor
	func convertImageToData(completionHandler: @escaping () -> Void) {
		for image in uiImages {
			if let compressedImageData = image.jpegData(compressionQuality: 0.5) {
				imagesData.append(compressedImageData)
			}
		}
		completionHandler()
	}
    
	func getDiaryPosts() {
		self.diaryPosts = persistence.read()
	}
	
	func createDiaryPost() {
		persistence.create(title: title, contents: contents, images: imagesData)
		getDiaryPosts()
       
        print("diary object is \(diaryPosts)")
	}
	
	func deleteDiaryPost(_ diaryPost: DiaryPost) {
		persistence.delete(diaryPost)
		getDiaryPosts()
	}
	
	func clearStates() {
		title = ""
		contents = ""
		imagesData = []
        uiImages = []
	}
}
