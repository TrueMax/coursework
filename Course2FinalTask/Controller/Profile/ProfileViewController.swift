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
    
    var currentUserID: User.Identifier? {
        didSet {
            setupViewController()
        }
    }
    
    var userProfile: User?
    var postsProfile: [Post]?
    let alert: AlertFactory
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        alert = AlertFactory()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startActivityIndicator()
    }
    
    func startActivityIndicator() {
        indicatorView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        indicatorView.isHidden = true
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
        print(postsProfile.count)
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
        
        //        view.setHeader(user: selectUser(user: userProfile))
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

//MARK: setViewController
extension ProfileViewController {
    
    func setupViewController() {
        
        if isViewLoaded { startActivityIndicator()
        }
        
        dataProvidersUser.user(with: currentUserID!, queue: queue) { user in
            guard let user = user else {
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.present(self.alert.createAlert(error: .noUserError), animated: false, completion: nil)
                }
                return
            }
            self.userProfile = user
            
            dataProvidersPosts.findPosts(by: user.id, queue: queue) { post in
                
                if let post = post {
                    self.postsProfile = post
                    
                    DispatchQueue.main.async {
                        self.stopActivityIndicator()
                        self.view.backgroundColor = viewBackgroundColor
                        self.title = self.userProfile?.username
                        self.tabBarItem.title = ControllerSet.profileViewController
                        self.profileCollectionView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.stopActivityIndicator()
                        self.present(self.alert.createAlert(error: .noPostError), animated: false, completion: nil)
                    }
                }
            }
        }
    }
}

//MARK: ProfileHeaderDelegate
extension ProfileViewController {
    
    func openFollowersList() {
        let userListViewController = UserListViewController()
        //        guard let followers = dataProvidersUser.usersFollowedByUser(with: selectUser(user: userProfile).id) else { return }
        guard let userProfile = userProfile?.id else { return }
        
        dataProvidersUser.usersFollowedByUser(with: userProfile, queue: queue) { users in
            guard let users = users else { return }
            userListViewController.usersList = users
            
            userListViewController.navigationItemTitle = NamesItemTitle.followers
            self.navigationController?.pushViewController(userListViewController, animated: true)
        }
        //        userListViewController.usersList = followers
        //        userListViewController.navigationItemTitle = NamesItemTitle.followers
        //        self.navigationController?.pushViewController(userListViewController, animated: true)
    }
    
    func openFollowingList() {
        let userListViewController = UserListViewController()
        guard let userProfile = userProfile?.id else { return }
        dataProvidersUser.usersFollowingUser(with: userProfile, queue: queue, handler: { users in
            guard let users = users else { return }
            
            userListViewController.usersList = users
            userListViewController.navigationItemTitle = NamesItemTitle.following
            self.navigationController?.pushViewController(userListViewController, animated: true)
        })
        
        //        userListViewController.usersList = following
        //        userListViewController.navigationItemTitle = NamesItemTitle.following
        //        self.navigationController?.pushViewController(userListViewController, animated: true)
        
    }
}
