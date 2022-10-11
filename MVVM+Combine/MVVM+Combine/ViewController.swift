//
//  ViewController.swift
//  MVVM+Combine
//
//  Created by Chowdhury Md Rajib  Sarwar on 11/10/22.
//

import UIKit
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


struct User: Decodable {
    let id: Int
    let name: String
    let email: String
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
