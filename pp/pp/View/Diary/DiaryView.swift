//
//  DiaryView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI
//import Kingfisher

struct DiaryView: View {

//	@ObservedObject var categoryViewModel: DiaryViewModel
	
	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 0){
				LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 21) {
//					ForEach(categoryViewModel.categories, id: \.self) { category in
//						NavigationLink(destination: CategoryDetailView(categoryDeatilViewModel: CategoryDetailViewModel(useCase: CategoryUseCase(repository: CategoryRepository())),
//																	   searchValue: "",
//																	   subCategoryInfo: SubCategoryInfo(),
//																	   mainCategorySeq: category.id ?? 0)) {
//							VStack {
//								KFImage(URL(string: "\(ServerUrl.imageCloudFront.baseUrl)\(category.imagePath ?? "")"))
//									.resizable()
//									.scaledToFit()
//								
//								Text(category.name ?? "")
//									.frame(height: 16)
//									.foregroundColor(Color(hex: "#5C6270"))
//									.font(.system(size: 12, weight: .medium))
//							}
//						}
//					}
				}
				.padding(.init(top: 20, leading: 16, bottom: 40, trailing: 16))
			}
		}
	}
}

#Preview {
    DiaryView()
}
