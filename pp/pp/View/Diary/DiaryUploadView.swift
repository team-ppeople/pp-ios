//
//  DiaryUploadView.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import SwiftUI

struct DiaryUploadView: View {
	@ObservedObject var vm: DiaryViewModel = DiaryViewModel()
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
    var body: some View {
		VStack {
			Button {
				print("picker")
			} label: {
				Image(systemName: "camera.fill")
					.tint(.sub)
			}
			.frame(width: 65, height: 65)
			.background(Color("#F3F3F3"))
			.cornerRadius(5)
			.overlay(RoundedRectangle(cornerRadius: 5).stroke(.sub, lineWidth: 1))
			
			TextField("Title", text: $vm.title)
                
			TextField("Body", text: $vm.contents)
			
			Button("작성 완료", action: {
				vm.createDiaryPost()
				vm.clearStates()
				presentationMode.wrappedValue.dismiss()
			})
			.frame(width: 120, height: 40)
			.background(.sub)
			.cornerRadius(5)
		}
		.navigationTitle("업로드")
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    DiaryUploadView()
}
