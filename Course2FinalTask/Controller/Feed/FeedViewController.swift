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
        
        title = ControllerSet.feedViewController
    }
}

//MARK: DataSource
extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        postsFeed.count
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
        let post = postsFeed[indexPath.row]
        cell.setupFeed(post: post)
        cell.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let post = posts.feed()[indexPath.row]
        let estimatedFrame = NSString(string: post.description).boundingRect(with: CGSize(width: width - 8, height: width - 8), options: .usesLineFragmentOrigin, attributes: nil, context: nil)
        return CGSize(width: width, height: estimatedFrame.height + width + 130)
    }
}

// MARK: FeedCollectionViewProtocol
extension FeedViewController: FeedCollectionViewProtocol {
    
    /// открывает профиль пользователя
    func openUserProfile(cell: FeedCollectionViewCell) {
        
        guard let indexPath = feedCollectionView.indexPath(for: cell) else { return }
        
        let currentPost = postsFeed[indexPath.row]
        
        guard let author = users.user(with: currentPost.author) else { return }
        
        let authorPosts = posts.findPosts(by: author.id)
        
        let profileViewController = ProfileViewController.initFromNib()
        profileViewController.userProfile = author
        profileViewController.postsProfile = authorPosts
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    /// ставит лайк на публикацию
    func likePost(cell: FeedCollectionViewCell) {
        guard let indexPath = feedCollectionView.indexPath(for: cell) else { return }
        
        let postID = postsFeed[indexPath.row].id
        
        guard cell.likeButton.tintColor == lightGrayColor else {
            if posts.unlikePost(with: postID) {
                postsFeed[indexPath.row].currentUserLikesThisPost = false
                postsFeed[indexPath.row].likedByCount -= 1
                cell.tintColor = lightGrayColor
                feedCollectionView.reloadData()
            }
            return
        }
        if posts.likePost(with: postID) {
            postsFeed[indexPath.row].currentUserLikesThisPost = true
            postsFeed[indexPath.row].likedByCount += 1
            cell.tintColor = defaultTintColor
            feedCollectionView.reloadData()
        }
    }
    
    /// открывает список пользователей поставивших лайк
    func userList(cell: FeedCollectionViewCell) {
        
        var userMarkerPost = [User]()
        
        guard let indexPath = feedCollectionView.indexPath(for: cell) else { return }
        
        let currentPostID = postsFeed[indexPath.row].id
        
        guard let usersID = posts.usersLikedPost(with: currentPostID) else { return }
        
        userMarkerPost = usersID.compactMap{ currentUserID in
            users.user(with: currentUserID) }
        
        guard !userMarkerPost.isEmpty else { return }
        
        let userListViewController = UserListViewController.initFromNib()
        userListViewController.usersList = userMarkerPost
        userListViewController.navigationItemTitle = NamesItemTitle.likes
        self.navigationController?.pushViewController(userListViewController, animated: true)
    }
}
