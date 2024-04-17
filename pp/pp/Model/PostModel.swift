//
//  PostModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation

// 작성한 글 서버에 올리는 구조체
struct PostRequest: Codable {
    var title: String
    var content: String
    var postImageFileUploadIds: [Int]
}

// 서버에서 글 받아오는 구조체
struct Post: Codable, Identifiable {
    let id: Int
    let thumbnailUrl: String
    let title: String
    let createDate: String
}

struct PostsResponse: Codable {
    let data: PostsData
}

struct PostsData: Codable {
    let posts: [Post]
}
