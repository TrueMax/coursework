//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Aleksey Bardin on 24.02.2020.
//  Copyright © 2020 Bardincom. All rights reserved.
//

import UIKit
import DataProvider

final class ProfileViewController: UIViewController, NibInit {
    
    var userProfile: User?
    var postsProfile: [Post]?
    
    @IBOutlet weak private var profileCollectionView: UICollectionView! {
        willSet {
            newValue.register(nibCell: ProfileCollectionViewCell.self)
            newValue.register(nibSupplementaryView: ProfileHeaderCollectionReusableView.self, kind: UICollectionView.elementKindSectionHeader)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
    }
}

//MARK: DataSourse
extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectPosts(posts: postsProfile).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionView.dequeue(cell: ProfileCollectionViewCell.self, for: indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ProfileCollectionViewCell else {
            assertionFailure()
            return
        }
        let post = selectPosts(posts: postsProfile)[indexPath.row]
        cell.setImageCell(post: post)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let view = view as? ProfileHeaderCollectionReusableView else {
            assertionFailure()
            return  }
        
        view.setHeader(user: selectUser(user: userProfile))
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
        if userProfile == nil {
            userProfile = currentUser
        }
        view.backgroundColor = viewBackgroundColor
        title = userProfile?.username
        tabBarItem.title = ControllerSet.profileViewController
        postsProfile = posts.findPosts(by: selectUser(user: userProfile).id)
    }
}

//MARK: ProfileHeaderDelegate
extension ProfileViewController: ProfileHeaderDelegate {
    
    func openFollowersList() {
        guard let followers = users.usersFollowedByUser(with: selectUser(user: userProfile).id) else { return }
        let userListViewController = UserListViewController.initFromNib()
        
        userListViewController.usersList = followers
        userListViewController.navigationItemTitle = NamesItemTitle.followers
        self.navigationController?.pushViewController(userListViewController, animated: true)
    }
    
    func openFollowingList() {
        guard let following = users.usersFollowingUser(with: selectUser(user: userProfile).id) else { return }
        let userListViewController = UserListViewController.initFromNib()
        userListViewController.usersList = following
        userListViewController.navigationItemTitle = NamesItemTitle.following
        self.navigationController?.pushViewController(userListViewController, animated: true)
    }
}
