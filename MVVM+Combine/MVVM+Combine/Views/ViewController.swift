//
//  ViewController.swift
//  MVVM+Combine
//
//  Created by Chowdhury Md Rajib  Sarwar on 11/10/22.
//

import UIKit
import Combine

class UsersTableViewController: UITableViewController {

    var viewModel: UsersViewModel!
    private let apiManger = APIManager()
    private var subscriber: AnyCancellable?
    
    var users:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        fetchUser()
        observeViewModel()
    }
    
    func setupViewModel() {
        viewModel = UsersViewModel(apiManager: apiManger, endPoint: .usersFetch)
    }
    
    func fetchUser() {
        viewModel.fetchUser()
    }
    
    func observeViewModel() {
        subscriber = viewModel.userSubject.sink { (resultCompletion) in
            switch resultCompletion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished: break
            }
        } receiveValue: { (users) in
            DispatchQueue.main.async {
                self.users = users
                self.tableView.reloadData()
            }
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let user = users[indexPath.row]
        cell.textLabel?.text  = user.name
        cell.detailTextLabel?.text  = user.email
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
}


