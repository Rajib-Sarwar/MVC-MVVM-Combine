//
//  APIManager.swift
//  MVVM+Combine
//
//  Created by Chowdhury Md Rajib  Sarwar on 12/10/22.
//

import Foundation
import Combine

class APIManager {
    
    private var subscribers = Set<AnyCancellable>();
    
    func fetchItems<T: Decodable>(url: URL, completion: @escaping (Result<[T], Error>) -> Void) {
        URLSession.shared.dataTaskPublisher(for: url)
            .map{ $0.data }
            .decode(type: [T].self, decoder: JSONDecoder())
            .sink { (resultCompletion) in
                switch resultCompletion {
                case .failure(let error):
                    completion(.failure(error))
                case .finished: break
                }
            } receiveValue: { (resultArray) in
                completion(.success(resultArray))
            }
            .store(in: &subscribers)

    }
}

enum EndPoint {
    case usersFetch
    case userComments
    var urlString: String {
        switch self {
        case .usersFetch:
            return "https://jsonplaceholder.typicode.com/users"
        case .userComments:
            return "https://jsonplaceholder.typicode.com/comments"
        }
    }
}
