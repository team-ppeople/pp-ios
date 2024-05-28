//
//  CommunityService.swift
//  pp
//
//  Created by 김지현 on 2024/05/07.
//

import Moya
import Combine


	//MARK: - Community API 통신
class CommunityService {
	static let shared = CommunityService()
	
	private var cancellables = Set<AnyCancellable>()
	
	lazy var provider = MoyaProvider<CommunityAPI>(plugins: [networkLogger])
	lazy var networkLogger = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))

	func uploadImageToPresignedURL(presignedURL: String, imageData: Data) -> AnyPublisher<Void, APIError> {
		provider.requestPublisher(.uploadImage(presignedURL: presignedURL, imageData: imageData))
			.map { _ in Void() }
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	//MARK: - 사진 업로드 ID + 커뮤니티 게시글 작성
	func uploadPostWithImages(title: String, content: String, imageUploads: [ImageUpload], presignedRequests: [PresignedUploadUrlRequests]) -> AnyPublisher<Void, APIError> {
		return getPresignedId(requestData: presignedRequests)
			.flatMap { presignedResponse -> AnyPublisher<Void, APIError> in
				let uploadPublishers = presignedResponse.data.presignedUploadFiles.enumerated().map { (index, file) in
					self.uploadImageToPresignedURL(presignedURL: file.presignedUploadUrl, imageData: imageUploads[index].imageData)
						.mapError(Utils.handleError)
				}
				
				return Publishers.MergeMany(uploadPublishers)
					.collect()
					.flatMap { _ -> AnyPublisher<Void, APIError> in
						let imageIds = presignedResponse.data.presignedUploadFiles.map { $0.fileUploadId }
						let postRequest = PostRequest(title: title, content: content, postImageFileUploadIds: imageIds)
						return self.createPost(post: postRequest)
					}
					.eraseToAnyPublisher()
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	
	//MARK: - 사진 업로드 가능 ID 검증
	func getPresignedId(requestData: [PresignedUploadUrlRequests]) -> AnyPublisher<PresignedIdResponse, APIError> {
		return provider
			.requestPublisher(.getPresignedId(requestData: requestData))
			.tryMap { response in
				return try JSONDecoder().decode(PresignedIdResponse.self, from: response.data)
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	//MARK: - 커뮤니티 게시글 작성
	func createPost(post: PostRequest) -> AnyPublisher<Void, APIError> {
		return provider
			.requestPublisher(.createPost(post: post))
			.map { _ in Void() }
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	//MARK: - 커뮤니티 게시글 목록 조회
	func fetchPosts(limit: Int, lastId: Int?) -> AnyPublisher<PostsResponse, APIError> {
		return provider
			.requestPublisher(.fetchPostsLists(limit: limit, lastId: lastId))
			.tryMap { response -> PostsResponse in
				return try JSONDecoder().decode(PostsResponse.self, from: response.data)
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	//MARK: - 커뮤니티 게시글 상세 조회
	func fetchDetailPosts(postId: Int) -> AnyPublisher<PostDetailResponse, APIError> {
		return provider
			.requestPublisher(.fetchDetailPosts(postId: postId))
			.tryMap { response -> PostDetailResponse in
				// 로그 출력을 추가하여 응답 데이터 확인
				let responseData = String(data: response.data, encoding: .utf8) ?? "Invalid response data"
				print("Response data: \(responseData)")
				
				return try JSONDecoder().decode(PostDetailResponse.self, from: response.data)
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	

	// MARK: - 게시글 신고
	func reportPost(postId: Int) -> AnyPublisher<Void, APIError> {
		return provider
			.requestPublisher(.reportPost(postId: postId))
			.map { _ in Void() }
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	// MARK: - 게시글 좋아요
	func thumbsUpPost(postId: Int) -> AnyPublisher<Void, APIError> {
		return provider
			.requestPublisher(.thumbsUp(postId: postId))
			.map { _ in Void() }
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	// MARK: - 게시글 좋아요 취소
	func thumbsSidewayPost(postId: Int) -> AnyPublisher<Void, APIError> {
		return provider
			.requestPublisher(.thumbs_sideways(postId: postId))
			.map { _ in Void() }
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	// MARK: - 게시글 댓글 목록 조회
	func fetchComments(postId: Int, limit: Int = 20, lastId: Int? = nil) -> AnyPublisher<CommentsResponse, APIError> {
		return provider
			.requestPublisher(.fetchComments(postId: postId, limit: limit, lastId: lastId))
			.tryMap { response -> CommentsResponse in
				return try JSONDecoder().decode(CommentsResponse.self, from: response.data)
			}
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	//MARK: - 커뮤니티 댓글 작성
	func writeComment(postId: Int, comment: CommentRequest) -> AnyPublisher<Void, APIError> {
		return provider
			.requestPublisher(.writeComments(postId: postId, comment: comment))
			.map { _ in Void() }
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
	
	//MARK: - 댓글 신고
	func reportComments(commentId: Int) -> AnyPublisher<Void, APIError> {
		return provider
			.requestPublisher(.reportComment(commentId: commentId))
			.map { _ in Void() }
			.mapError(Utils.handleError)
			.eraseToAnyPublisher()
	}
}
