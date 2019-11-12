//
//  TrendingDeveloperCell.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class TrendingDeveloperCell: BaseTableViewCell, View, CellType {

    typealias Reactor = TrendingDeveloperCellReactor
    
    // MARK: - UI
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var authorInfoStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var repoInfoStackView: UIStackView!
    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var repoDescLabel: UILabel!
    
    // MARK: - Properties
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    fileprivate func configureUI() {
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.layer.masksToBounds = true
    }
    
    fileprivate func reset() {
        userNameLabel.isHidden = false
        repoDescLabel.isHidden = false
        profileImageView.image = nil
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        let rank = state.rank
        rankLabel.text = "\(rank)"
        
        let profileURL = state.profileURL
        if let url = URL(string: profileURL) {
            profileImageView.kf.setImage(with: url)
        }
        
        let name = state.name
        nameLabel.text = name
        if let userName = state.userName {
            userNameLabel.text = userName
        } else {
            userNameLabel.isHidden = true
        }
        
        let repoName = state.repoName
        repoNameLabel.text = repoName
        if let repoDesc = state.repoDescription {
            repoDescLabel.text = repoDesc
        } else {
            repoDescLabel.isHidden = true
        }
    }
    
    func bind(reactor: Reactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
