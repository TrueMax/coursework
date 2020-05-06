//
//  UserListViewController.swift
//  Course2FinalTask
//
//  Created by Aleksey Bardin on 07.03.2020.
//  Copyright © 2020 Bardincom. All rights reserved.
//

import UIKit
import DataProvider

class UserListViewController: UIViewController, NibInit {
    
    var usersList: [User]?
    var userInList: User?
    var navigationItemTitle: String?
    
    @IBOutlet var userListTableView: UITableView! {
        willSet {
            newValue.register(nibCell: UserListTableViewCell.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationItemTitle = navigationItemTitle {
                  self.navigationItem.title = navigationItemTitle
              }
    }
}

//MARK: DataSource
extension UserListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let usersList = usersList else { return 0 }
        return usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeue(reusable: UserListTableViewCell.self, for: indexPath)
    }
}

//MARK: Delegate
extension UserListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navController = tabBarController?.viewControllers?[2] as? UINavigationController else { return }
        
        tabBarController?.selectedViewController = navController
        userListTableView.deselectRow(at: indexPath, animated: true)
    }
}
