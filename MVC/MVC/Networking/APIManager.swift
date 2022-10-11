//
//  APIManager.swift
//  MVC
//
//  Created by Chowdhury Md Rajib  Sarwar on 11/10/22.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    let urlString = "https://jsonplaceholder.typicode.com/users"
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let url = URL(string: urlString)!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                fatalError("Data cannot be found")
            }
            
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
