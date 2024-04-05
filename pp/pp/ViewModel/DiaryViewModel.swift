//
//  DiaryViewModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation

protocol DiaryViewModelProtocol {
	func getDiaryPostList()
}

class DiaryViewModel: DiaryViewModelProtocol, ObservableObject{
	
	// MARK: - 뷰에서 구독할 데이터
	@Published var diaryPosts: [DiaryPost] = []
	
//	private let useCase: CategoryUseCase

//	init(useCase: CategoryUseCase) {
//		self.useCase = useCase
//	}
	
	func getDiaryPostList() {
//		self.useCase.fetchCategoryList(completion: { result in
//			switch result {
//			case .success(let data):
//				self.categories = data
//			case .failure(let error):
//				print(error.localizedDescription)
//			}
//		})
		
		self.diaryPosts = [
//			DiaryPost(entity: <#T##NSEntityDescription#>, insertInto: <#T##NSManagedObjectContext?#>)
		]
	}
}
