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
    
    var userProfile: User? {
        didSet {
            setupViewController()
        }
    }
    var postsProfile: [Post]?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
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
        guard let postsProfile = postsProfile else { return [Post]().count }
        print(postsProfile.count)
        return postsProfile.count
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

        guard let postsProfile = postsProfile else { return }
        let post = postsProfile[indexPath.row]
        /// установка изображений
        cell.setImageCell(post: post)
    }
    
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
        
        
        if userProfile == nil {
            
            dataProvidersUser.currentUser(queue: queue) { [weak self] user in
                guard let user = user else { return }
                print(user)
                self?.userProfile = user

//                DispatchQueue.main.async {
//                    self?.view.backgroundColor = viewBackgroundColor
//                    self?.title = self?.userProfile?.username
//                    self?.tabBarItem.title = ControllerSet.profileViewController
//                    self?.profileCollectionView.reloadData()
//                }
            }
        }
        
        DispatchQueue.main.async {
            self.view.backgroundColor = viewBackgroundColor
            self.title = self.userProfile?.username
            self.tabBarItem.title = ControllerSet.profileViewController
            self.profileCollectionView.reloadData()
        }
        
//        view.backgroundColor = viewBackgroundColor
//        title = userProfile?.username
//        tabBarItem.title = ControllerSet.profileViewController
        
        guard let userProfile = userProfile?.id else {
            print("ТУТУТУ")
            return }
        dataProvidersPosts.findPosts(by: userProfile, queue: queue) { [weak self] post in

            guard let post = post else { return }
            print("findPosts \(post)")
            self?.postsProfile = post
            
            DispatchQueue.main.async {
                self?.profileCollectionView.reloadData()
            }

        }
    }
}

//MARK: ProfileHeaderDelegate
extension ProfileViewController: ProfileHeaderDelegate {
    
    func openFollowersList() {
        let userListViewController = UserListViewController.initFromNib()
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
        let userListViewController = UserListViewController.initFromNib()
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
