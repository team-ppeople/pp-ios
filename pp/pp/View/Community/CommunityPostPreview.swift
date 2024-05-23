//
//  CommunityPostPreview.swift
//  pp
//
//  Created by 임재현 on 5/5/24.
//

import SwiftUI

struct CommunityPostPreview: View {
    let vm: PostViewModel
    let communityPost: Post
	var size: CGFloat
    
    var body: some View {
        NavigationLink(destination: CommunityDetailView(vm: vm, postId:communityPost.id)) {
            VStack(alignment: .leading) {
               AsyncImage(url:communityPost.thumbnailURLs) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
						.frame(width: size, height: size, alignment: .center)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 10,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 10
                            ))
                    
                } placeholder: {
                    ProgressView()
						.frame(width: size, height: size, alignment: .center)
                    
                }
                
                Text(communityPost.title)
                    .font(.system(size: 15))
                    .tint(.black)
                    .lineLimit(1)
                    .frame(height: 18)
                    .padding(.horizontal, 10)
                
                Text(communityPost.createDate)
                    .font(.system(size: 12))
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                    .frame(height: 15)
                    .padding([.horizontal, .bottom], 10)
            }
            .background(RoundedRectangle(cornerRadius: 10).stroke(.sub))
        }
        
        .onAppear {
            if let url = communityPost.thumbnailURLs {
                print("Thumbnail URL: \(url)")
            }
        }
        
    }
}

