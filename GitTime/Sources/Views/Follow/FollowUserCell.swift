//
//  FollowUserCell.swift
//  GitTime
//
//  Created by Kanz on 04/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class FollowUserCell: BaseTableViewCell, View, CellType {

    typealias Reactor = FollowUserCellReactor
    
    // MARK: - UI
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    // MARK: - Properties
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        reset()
    }
    
    fileprivate func configureUI() {
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.layer.masksToBounds = true
    }
    
    fileprivate func reset() {
        userNameLabel.text = ""
        profileImageView.image = nil
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let profileURL = state.followUser.profileURL
        if let url = URL(string: profileURL) {
            profileImageView.kf.setImage(with: url)
        }
        
        let name = state.followUser.name
        userNameLabel.text = name
    }
    
    func bind(reactor: Reactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
