//
//  PostModel.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//

import Foundation
import UIKit




//MARK: - 사진 업로드 가능 ID 요청
struct PresignedUploadUrlRequests: Codable {
    let fileType: String
    let fileName:String
    let fileContentLength: Int
    let fileContentType: String
    
}

struct PresignedUploadUrlRequestData: Codable {
    let presignedUploadUrlRequests: [PresignedUploadUrlRequests]
}

//MARK: - 사진 업로드 가능 결과 수신
struct PresignedIdResponse: Codable {
    let data: PresignedIdData
}

struct PresignedIdData: Codable {
    let presignedUploadFiles: [PresignedUploadIdResponse]
}

struct PresignedUploadIdResponse: Codable {
    let fileUploadId: Int
    let fileName:String
    let presignedUploadUrl: String
    let fileUrl: String
   
}


//MARK: - AWS 서버에 이미지 업로드
struct ImageUpload {
    let imageData: Data
}

//MARK: - 작성한 글 서버에 올리는 구조체
struct PostRequest: Codable {
    var title: String
    var content: String
    var postImageFileUploadIds: [Int]
}


//MARK: - 서버에서 글 받아오는 구조체

struct Post: Codable, Identifiable,Hashable {
    let id: Int
    let thumbnailUrl: String?
    let title: String
    let createDate: String
    
    var thumbnailURLs: URL? {
		if let thumbnailUrl = thumbnailUrl {
			return URL(string: "\(thumbnailUrl)")
		} else {
			return nil
		}
    }
}

struct PostsResponse: Codable {
    let data: PostsData
}

struct PostsData: Codable {
    let posts: [Post]
}

//MARK: - 게시글 상세 조회

struct PostDetailResponse: Codable {
    let data: PostDetail
}

struct PostDetail: Codable {
    let createdUser: CreatedUser
    let id: Int
    let postImageUrls: [String]
    let title: String
    let content: String
    let createdDate: String
    let thumbsUpCount: Int
    let commentCount: Int
    let userActionHistory: UserActionHistory

    var imageUrls: [URL] {
        postImageUrls.compactMap(URL.init)
    }

}


struct CreatedUser: Codable {
    let id: Int
    let nickname: String
    let profileImageUrl: String
   var profileImageURL: URL? {
           URL(string: profileImageUrl)
       }
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

struct Comment: Codable,Identifiable {
    let id: Int
    let content: String
    let createDate: String
    let createdUser: CreatedUser
}

//MARK: - 댓글 작성
struct CommentRequest: Codable {
    var content: String
   
}
