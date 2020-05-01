//
//  FeedViewController.swift
//  Course2FinalTask
//
//  Created by Aleksey Bardin on 24.02.2020.
//  Copyright © 2020 Bardincom. All rights reserved.
//

import UIKit
import DataProvider


final class FeedViewController: UIViewController, NibInit {
    
    var currentUser: User?
    var postsArray: [Post] = []
    
    @IBOutlet weak private var feedCollectionView: UICollectionView!
        {
        willSet {
            newValue.register(nibCell: FeedCollectionViewCell.self)
        }
    }
    
    @IBOutlet weak private var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
           dataProvidersPosts.feed(queue: queue) { posts in
                 guard let posts = posts else { return }
            print(posts.count)
            self.postsArray = posts
            DispatchQueue.main.async {
                print("Test")
                
                self.feedCollectionView.reloadData()
            }
                 
             }
        
        title = ControllerSet.feedViewController
    }
}

//MARK: DataSource
extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionView.dequeue(cell: FeedCollectionViewCell.self, for: indexPath)
    }
}

//MARK: DelegateFlowLayout
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? FeedCollectionViewCell else {
            assertionFailure()
            return
        }
        //        let post = postsFeed[indexPath.row]
        dataProvidersPosts.feed(queue: queue) { posts in
            guard let posts = posts else { return }
            self.postsArray = posts
        }
        let post = postsArray[indexPath.row]
  
            cell.setupFeed(post: post)
            cell.delegate = self

        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        
        dataProvidersPosts.feed(queue: queue) { posts in
            guard let posts = posts else { return }
            self.postsArray = posts
        }
        
        let post = postsArray[indexPath.row]
        let estimatedFrame = NSString(string: post.description).boundingRect(with: CGSize(width: width - 8, height: width - 8), options: .usesLineFragmentOrigin, attributes: nil, context: nil)
       
        return CGSize(width: width, height: estimatedFrame.height + width + 130)
    }
}

// MARK: FeedCollectionViewProtocol
extension FeedViewController: FeedCollectionViewProtocol {
    
    /// открывает профиль пользователя
    func openUserProfile(cell: FeedCollectionViewCell) {
        let profileViewController = ProfileViewController.initFromNib()
        guard let indexPath = feedCollectionView.indexPath(for: cell) else { return }
        
        let currentPost = postsArray[indexPath.row]
        
        
        dataProvidersUser.user(with: currentPost.author, queue: queue, handler: { user in
            guard let user = user else { return }
            
            profileViewController.userProfile = user
            
        })
        
        guard let authorID = profileViewController.userProfile?.id else { return }
        
        //        let authorPosts = postsArray.findPosts(by: author.id)
        dataProvidersPosts.findPosts(by: authorID, queue: queue) { posts in
            guard let posts = posts else { return }
            profileViewController.postsProfile = posts
            
        }
        
        //        let profileViewController = ProfileViewController.initFromNib()
        //        profileViewController.userProfile = author
        //        profileViewController.postsProfile = postsArray
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    /// ставит лайк на публикацию
    func likePost(cell: FeedCollectionViewCell) {
        
        guard let indexPath = feedCollectionView.indexPath(for: cell) else { return }
        
        dataProvidersPosts.feed(queue: queue) { post in
            guard let post = post else { return }
            self.postsArray = post
        }
        
        let postID = postsArray[indexPath.row].id
        dataProvidersPosts.unlikePost(with: postID, queue: queue) { unlikePost in
            guard let unlikePost = unlikePost else { return }
            //            self = unlikePost
            
        }
        
        dataProvidersPosts.likePost(with: postID, queue: queue) { likePost in
            guard let unlikePost = likePost else { return }
            //            self.post = unlikePost
        }
        
        guard cell.likeButton.tintColor == lightGrayColor else {
            //            guard post.currentUserLikesThisPost else { return }
            postsArray[indexPath.row].currentUserLikesThisPost = false
            postsArray[indexPath.row].likedByCount -= 1
            cell.tintColor = lightGrayColor
            feedCollectionView.reloadData()
            return
        }
        
        //        guard !post.currentUserLikesThisPost else { return }
        postsArray[indexPath.row].currentUserLikesThisPost = true
        postsArray[indexPath.row].likedByCount += 1
        cell.tintColor = defaultTintColor
        feedCollectionView.reloadData()
        
    }
    
    /// открывает список пользователей поставивших лайк
    func userList(cell: FeedCollectionViewCell) {
        
        /// массив пользователей поставивших лайк
        var userMarkerPost = [User]()
        //        var userID: User.Identifier
        //        var foundUser1: User
        
        guard let indexPath = feedCollectionView.indexPath(for: cell) else { return }
        
        dataProvidersPosts.feed(queue: queue) { post in
            guard let post = post else { return }
            self.postsArray = post
        }
        
        //        let currentPostID = postsFeed[indexPath.row].id
        let currentPostID = postsArray[indexPath.row].id
        
        dataProvidersPosts.usersLikedPost(with: currentPostID, queue: queue) { usersArray in
            guard let usersArray = usersArray else { return }
            userMarkerPost = usersArray
        }
        
        //        guard let usersID = posts.usersLikedPost(with: currentPostID) else { return }
        
        //        userMarkerPost = usersID.compactMap{ currentUserID in
        //            dataProvidersUser.user(with: currentUserID) }
        
        //        userMarkerPost.forEach { user in
        //            dataProvidersUser.user(with: user.id, queue: queue) { foundUser in
        //                guard let user = foundUser else { return }
        //                foundUser1 = user
        //            }
        //        }
        
        
        guard !userMarkerPost.isEmpty else { return }
        
        let userListViewController = UserListViewController.initFromNib()
        userListViewController.usersList = userMarkerPost
        userListViewController.navigationItemTitle = NamesItemTitle.likes
        self.navigationController?.pushViewController(userListViewController, animated: true)
    }
}
