//
//  SearchUserCell.swift
//  GitTime
//
//  Created by Kanz on 03/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SearchUserCell: BaseTableViewCell, View, CellType {
    
    typealias Reactor = SearchUserCellReactor
    
    // MARK: - UI
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var organizationView: UIView!
    
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
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        
        organizationView.layer.cornerRadius = 4.0
        organizationView.layer.masksToBounds = true
        organizationView.layer.borderWidth = 0.5
        organizationView.layer.borderColor = UIColor(red: 0.64, green: 0.87, blue: 0.93, alpha: 1.00).cgColor
    }
    
    fileprivate func reset() {
        userNameLabel.text = ""
        profileImageView.image = nil
        organizationView.isHidden = true
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let profileURL = state.user.profileURL
        if let url = URL(string: profileURL) {
            profileImageView.kf.setImage(with: url)
        }
        
        let name = state.user.name
        userNameLabel.text = name
        
        organizationView.isHidden = state.user.type == .user
    }
    
    func bind(reactor: Reactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
