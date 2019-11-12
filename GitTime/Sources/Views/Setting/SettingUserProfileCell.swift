//
//  SettingUserProfileCell.swift
//  GitTime
//
//  Created by Kanz on 05/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SettingUserProfileCell: BaseTableViewCell, View, CellType {
    
    typealias Reactor = SettingUserProfileCellReactor

    // MARK: - UI
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followerTitleLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var follwingTitleLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    fileprivate func configureUI() {
        
        self.backgroundColor = .lightBackground
        self.contentView.backgroundColor = .lightBackground
        
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.layer.masksToBounds = true
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let profileURL = state.profileURL
        if let url = URL(string: profileURL) {
            profileImageView.kf.setImage(with: url)
        }
        
        let name = state.name
        nameLabel.text = name
        
        let followersCount = state.followerCount
        followerLabel.text = followersCount.formatUsingAbbrevation()
        
        let followingCount = state.follwingCount
        followingLabel.text = followingCount.formatUsingAbbrevation()
    }
    
    func bind(reactor: Reactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
