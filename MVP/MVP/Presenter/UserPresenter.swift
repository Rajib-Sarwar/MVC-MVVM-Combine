//
//  UserPresenter.swift
//  MVP
//
//  Created by Chowdhury Md Rajib  Sarwar on 12/10/22.
//

import Foundation
import UIKit

protocol UserPresenterDelegate: AnyObject {
    func fetchUsers(users: [User])
    func failure(error: Error)
}

typealias PresenterDelegate = UserPresenterDelegate & UIViewController
class UserPresenter {
    weak var delegate: UserPresenterDelegate?
    
    func fetchUsers() {
        APIManager.shared.fetchUsers { [weak self](result) in
            switch result {
            case .success(let users):
                self?.delegate?.fetchUsers(users: users)
            case .failure(let error):
                self?.delegate?.failure(error: error)
            }
        }
    }
    
    func setViewDelegate(delegate: PresenterDelegate) {
        self.delegate = delegate
    }
}
