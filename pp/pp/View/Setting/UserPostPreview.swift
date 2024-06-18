//
//  UserPostPreview.swift
//  pp
//
//  Created by 임재현 on 5/29/24.
//
//

import SwiftUI

struct UserPostPreview: View {
    let post: Post
    var size: CGFloat

    var body: some View {
        NavigationLink(destination: CommunityDetailView(vm: CommunityViewModel(), postId: post.id)) {
            VStack(alignment: .leading) {
                AsyncImage(url: post.thumbnailURLs) { phase in
                    switch phase {
                    case .empty:
                        Image("empty.image")
							.resizable()
							.aspectRatio(contentMode: .fill)
							.frame(width: size, height: size)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
							.clipShape(
								.rect(
									topLeadingRadius: 10,
									bottomLeadingRadius: 0,
									bottomTrailingRadius: 0,
									topTrailingRadius: 10
								))
                    case .failure:
						ProgressView()
							.frame(width: size, height: size, alignment: .center)
                    @unknown default:
                        EmptyView()
                    }
                }
				
                Text(post.title)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .frame(height: 18)
                    .padding(.horizontal, 10)
                Text(post.createDate)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(height: 15)
                    .padding([.horizontal, .bottom], 10)
            }
			.background(RoundedRectangle(cornerRadius: 10).stroke(.sub))
        }
    }
}
