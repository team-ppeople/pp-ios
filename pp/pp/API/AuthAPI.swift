//
//  AuthEndpoint.swift
//  pp
//
//  Created by Financial CB on 2024/04/03.
//


import Foundation
import Combine

class PostService {
    static let shared = PostService()
    
    private init() {}
    
    //MARK: - 커뮤니티 게시글 작성
    func createPost(post: PostRequest) -> AnyPublisher<Void, Error> {
      
        // API URL 추가 예정
        guard let url = URL(string: "https://") else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(post)
            request.httpBody = jsonData
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      response.statusCode == 201 else {
                    throw URLError(.badServerResponse)
                }
            }
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    
    //MARK: - 커뮤니티 게시글 목록 조회
    func fetchPosts(limit: Int = 20, lastId: Int?) -> AnyPublisher<PostsResponse, Error> {
        var components = URLComponents(string: "https://your-api-url.com/posts")
        var queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        if let lastId = lastId {
            queryItems.append(URLQueryItem(name: "lastId", value: String(lastId - 1)))
        }
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            fatalError("Invalid URL")
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      response.statusCode == 201 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: PostsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    
    
    
    
}



//


