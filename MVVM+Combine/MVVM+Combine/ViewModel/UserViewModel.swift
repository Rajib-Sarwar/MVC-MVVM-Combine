//
//  UserViewModel.swift
//  MVVM+Combine
//
//  Created by Chowdhury Md Rajib  Sarwar on 12/10/22.
//

import Foundation
import Combine

class UsersViewModel {
    //depenndency injection
    private let apiManager: APIManager
    private let endPoint: EndPoint
    
    var userSubject = PassthroughSubject<[User], Error>()
    
    init(apiManager: APIManager, endPoint: EndPoint) {
        self.apiManager = apiManager
        self.endPoint = endPoint
    }
    
    func fetchUser() {
        let url = URL(string: endPoint.urlString)!
        apiManager.fetchItems(url: url) { [weak self] (result: Result<[User], Error>) in
            switch result {
            case .success(let users):
                self?.userSubject.send(users)
            case .failure(let error):
                self?.userSubject.send(completion: .failure(error))
            }
        }
    }
}
