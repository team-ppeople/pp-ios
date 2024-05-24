//
//  UserProfileView.swift
//  pp
//
//  Created by 임재현 on 5/25/24.
//

import SwiftUI

struct UserProfileView: View {
    var body: some View {
        VStack {
            HStack {
                Image("empty.image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .padding(8)
                
                Text("바다거북맘")
                    .font(.title3)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal, 32)
                .padding(.top, 16)
            
            HStack(spacing: 0) {
                VStack {
                    Text("게시글수")
                    Text("1")
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 1, height: 50)
                    .background(Color.gray)
                
                VStack {
                    Text("받은 좋아요 수")
                    Text("8")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
            DiaryView()
        }
        .padding(.top, 16)
        
        Spacer()
    }
}
