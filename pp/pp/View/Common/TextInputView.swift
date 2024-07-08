//
//  TextInputView.swift
//  pp
//
//  Created by 김지현 on 2024/05/23.
//

import SwiftUI

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
                .padding(.top, 20)
            TextEditor(text: $contents)
                .frame(height: 200)
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
