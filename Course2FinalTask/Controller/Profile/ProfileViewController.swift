//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Aleksey Bardin on 24.02.2020.
//  Copyright © 2020 Bardincom. All rights reserved.
//

import UIKit
import DataProvider

final class ProfileViewController: UIViewController, ProfileHeaderDelegate {
    
    var feedUserID: User.Identifier?
    var userProfile: User?
    var postsProfile: [Post]?
    lazy var alert: AlertFactory = {
        return AlertFactory()
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        tabBarController?.delegate = self
        
        
        let item = CustomBackButton(target: self, selector: #selector(returnToFeedController), title: "Feed")
        navigationItem.leftBarButtonItem = item
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let id = feedUserID {
            loadUserByProfile(id: id)
        } else {
            loadCurrentUser()
        }
    }
    
    @objc func returnToFeedController() {
        feedUserID = nil
        tabBarController?.selectedIndex = 0
    }
    
    func loadUserByProfile(id: User.Identifier) {
        
        startActivityIndicator()
        feedUserID = id
        dataProvidersUser.user(with: id, queue: queue) { user in
            guard let user = user else {
                self.presentAlert(error: .noUserError)
                return
            }
            self.userProfile = user
            
            dataProvidersPosts.findPosts(by: user.id, queue: queue) { posts in
                guard let cPosts = posts else {
                    self.presentAlert(error: .noPostError)
                    return
                }
                self.postsProfile = cPosts
                self.updateUI()
            }
        }
    }
    
    func loadCurrentUser() {
        
        startActivityIndicator()
        dataProvidersUser.currentUser(queue: queue) { user in
            guard let cUser = user else {
                self.presentAlert(error: .noUserError)
                return
            }
            self.userProfile = cUser
            
            dataProvidersPosts.findPosts(by: cUser.id, queue: queue) { posts in
                guard let cPosts = posts else {
                    self.presentAlert(error: .noPostError)
                    return
                }
                self.postsProfile = cPosts
                self.updateUI()
            }
        }
    }
        
    
    func startActivityIndicator() {
        indicatorView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        indicatorView.isHidden = true
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.stopActivityIndicator()
            self.view.backgroundColor = viewBackgroundColor
            self.title = self.userProfile?.username
            self.tabBarItem.title = ControllerSet.profileViewController
            self.profileCollectionView.reloadData()
        }
    }
    
    func presentAlert(error: DataProviderError) {
        DispatchQueue.main.async {
            self.stopActivityIndicator()
            self.present(self.alert.createAlert(error: error), animated: false, completion: nil)
        }
    }
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak private var profileCollectionView: UICollectionView! {
        willSet {
            newValue.register(nibCell: ProfileCollectionViewCell.self)
            newValue.register(nibSupplementaryView: ProfileHeaderCollectionReusableView.self, kind: UICollectionView.elementKindSectionHeader)
        }
    }
}

//MARK: DataSourse
extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let postsProfile = postsProfile else { return [Post]().count }
        return postsProfile.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeue(cell: ProfileCollectionViewCell.self, for: indexPath)
        
        guard let postsProfile = postsProfile else { return UICollectionViewCell() }
        let post = postsProfile[indexPath.item]
        /// установка изображений
        cell.setImageCell(post: post)
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        return collectionView.dequeue(supplementaryView: ProfileHeaderCollectionReusableView.self,
                                      kind: kind, for: indexPath)
    }
    
    /// задаю размеры Header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 86)
    }
}

//MARK: Delegate FlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let view = view as? ProfileHeaderCollectionReusableView else {
            assertionFailure()
            return  }

        guard let userProfile = userProfile else { return }
        /// устновка Хедера
        view.setHeader(user: userProfile)
        view.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = profileCollectionView.bounds.width / 3
        return CGSize(width: size, height: size)
    }
    
}

//MARK: ProfileHeaderDelegate
extension ProfileViewController {
    
    func openFollowersList() {

        let userListViewController = UserListViewController()
        
        guard let userProfile = userProfile?.id else { return }
        
        dataProvidersUser.usersFollowedByUser(with: userProfile, queue: queue) { users in
            guard let users = users else { return }
            userListViewController.usersList = users
            
            DispatchQueue.main.async {
                userListViewController.navigationItemTitle = NamesItemTitle.followers
                self.navigationController?.pushViewController(userListViewController, animated: true)
            }
        }
    }
    
    func openFollowingList() {

        let userListViewController = UserListViewController()
        
        guard let userProfile = userProfile?.id else { return }
        
        dataProvidersUser.usersFollowingUser(with: userProfile, queue: queue, handler: { users in
            guard let users = users else { return }
            
            userListViewController.usersList = users
            
            DispatchQueue.main.async {
                userListViewController.navigationItemTitle = NamesItemTitle.following
                self.navigationController?.pushViewController(userListViewController, animated: true)
            }
        })        
    }
}

extension ProfileViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === ProfileViewController.self {
            updateUI()
        }
    }
}

extension ProfileViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if !(viewController === navigationController) {
            feedUserID = nil
            navigationController?.popToRootViewController(animated: false)
        }
    }
}

class CustomBackButton: UIBarButtonItem {
    
    convenience init(target: Any, selector: Selector, title: String) {
        
        let button = UIButton(frame: .zero)
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        let config = UIImage.SymbolConfiguration(pointSize: 19.0, weight: .semibold, scale: .large)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        button.setImage(image, for: .normal)
        
        button.addTarget(target, action: selector, for: .touchUpInside)
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -18.0, bottom: 0.0, right: 0.0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -12.0, bottom: 0.0, right: 0.0)
        
        self.init(customView: button)
    }
}
