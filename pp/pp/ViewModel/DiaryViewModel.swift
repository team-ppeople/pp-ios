//
//  DiaryViewModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation

class DiaryViewModel: ObservableObject {
	@Published var diaryPosts: [DiaryPost] = []
	
	let dataService = PersistenceController.shared

	@Published var title: String = ""
	@Published var contents: String = ""
	@Published var images: Data = Data()
	
	init() {
		getDiaryPosts()
	}
	
	func getDiaryPosts() {
		self.diaryPosts = dataService.read()
	}
	
	func createDiaryPost() {
		dataService.create(title: title, contents: contents, images: images)
		getDiaryPosts()
	}
	
	func deleteDiaryPost(_ diaryPost: DiaryPost) {
		dataService.delete(diaryPost)
		getDiaryPosts()
	}
	
	func clearStates() {
		title = ""
		contents = ""
		images = Data()
	}
}
