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
    
    
    
    private func isValidInput(_ input: String) -> Bool {
          // 유효성 검사 - 공백문자만 있는지,Html 태그 방지,최소한 하나의 공백 아닌 문자 포함해야함
        let pattern = "^(?!\\s*$)(?!.*<[^>]+>).+"
          let regex = try? NSRegularExpression(pattern: pattern)
          let range = NSRange(location: 0, length: input.utf16.count)
          return regex?.firstMatch(in: input, options: [], range: range) != nil
      }
    
    
    
    
}
