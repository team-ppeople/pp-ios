//
//  PostModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation

//MARK: - 작성한 글 서버에 올리는 구조체
struct PostRequest: Codable {
    var title: String
    var content: String
    var postImageFileUploadIds: [Int]
}


//MARK: - 서버에서 글 받아오는 구조체

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




//MARK: - 게시글 상세 조회

struct PostDetailResponse: Codable {
    let data: PostDetailData
}

struct PostDetailData: Codable {
    let post: PostDetail
}

struct PostDetail: Codable {
    let createdUser: CreatedUser
    let id: Int
    let postImageUrls: [String]
    let title: String
    let content: String
    let createDate: String
    let thumbsUpCount: Int
    let commentCount: Int
    let userActionHistory: UserActionHistory
}

struct CreatedUser: Codable {
    let id: Int
    let nickname: String
    let profileImageUrl: String
}

struct UserActionHistory: Codable {
    let thumbsUpped: Bool
    let reported: Bool
}

//MARK: - 게시글 댓글 조회
struct CommentsResponse: Codable {
    let data: CommentsData
}

struct CommentsData: Codable {
    let comments: [Comment]
}

struct Comment: Codable {
    let id: Int
    let content: String
    let createDate: String
}

//MARK: - APIError Type

struct APIError: Decodable, Error {
    let type: String
    let title: String
    let status: Int
    let detail: String
    let instance: String
}
