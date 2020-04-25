//
//  ProfileHeaderCollectionReusableView.swift
//  Course2FinalTask
//
//  Created by Aleksey Bardin on 01.03.2020.
//  Copyright © 2020 Bardincom. All rights reserved.
//

import UIKit
import DataProvider

protocol ProfileHeaderDelegate {
    func openFollowersList()
    func openFollowingList()
}

final class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet private var avatarImage: UIImageView!
    @IBOutlet private var fullNameLabel: UILabel!
    @IBOutlet private var followersLabel: UILabel!
    @IBOutlet private var followingLabel: UILabel!
    
    var delegate: ProfileHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTapGestureRecognizer()
    }
    
    func setHeader(user: User) {
        avatarImage.image = user.avatar
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        fullNameLabel.font = systemsFont
        fullNameLabel.text = user.fullName
        followersLabel.font = systemsBoldFont
        followersLabel.text = "Followers: \(user.followsCount)"
        followingLabel.font = systemsBoldFont
        followingLabel.text = "Following: \(user.followedByCount)"
    }
}

//MARK: Selector
extension ProfileHeaderCollectionReusableView {
    
    @objc func followersTap() {
        delegate?.openFollowersList()
    }
    
    @objc func followingTap() {
        delegate?.openFollowingList()
    }
}

//MARK: TapGestureRecognizer
private extension ProfileHeaderCollectionReusableView {
    
    func setupTapGestureRecognizer() {
        let gestureFollowersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap))
        followersLabel.addGestureRecognizer(gestureFollowersTap)
        
        let gestureFollowingTap = UITapGestureRecognizer(target: self, action: #selector(followingTap))
        followingLabel.addGestureRecognizer(gestureFollowingTap)
    }
}
