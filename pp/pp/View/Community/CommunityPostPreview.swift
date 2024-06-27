//
//  CommunityPostPreview.swift
//  pp
//
//  Created by 임재현 on 5/5/24.
//

import SwiftUI

struct CommunityPostPreview: View {
    let vm: CommunityViewModel
    let communityPost: Post
	var size: CGFloat
    
    var body: some View {
        NavigationLink(destination: CommunityDetailView(vm: vm, postId: communityPost.id)) {
            VStack(alignment: .leading) {
                if let thumbnailURLs = communityPost.thumbnailURLs {
                    GeometryReader { geometry in
                        AsyncImage(url: thumbnailURLs) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height,alignment: .center)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 10,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 10
                                    ))
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                    .frame(height: size)
                } else {
                    Image("empty.image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .clipped()
                }
                
                Text(communityPost.title)
                    .font(.system(size: 15))
                    .tint(.black)
                    .lineLimit(1)
                    .frame(height: 18)
                    .padding(.horizontal, 10)
                
				Text(Utils.toString(communityPost.createDate.toDate()))
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

