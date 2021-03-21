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

final class FollowUserCell: BaseTableViewCell, ReactorKit.View {

    typealias Reactor = FollowUserCellReactor
    
    // MARK: - UI
    private let profileImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.layer.cornerRadius = 8.0
		$0.layer.masksToBounds = true
		$0.contentMode = .scaleAspectFill
		$0.clipsToBounds = true
    }

    private let userNameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 16.0)
		$0.textColor = .title
    }

    // MARK: - Properties
    
	// MARK: - Initializing
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    fileprivate func reset() {
        userNameLabel.text = ""
        profileImageView.image = nil
    }
	
	// MARK: - UI Setup
	override func addViews() {
		super.addViews()
		
		self.contentView.addSubview(profileImageView)
		self.contentView.addSubview(userNameLabel)
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		profileImageView.snp.makeConstraints { make in
			make.width.height.equalTo(48.0)
			make.leading.equalTo(16.0)
			make.top.equalTo(8.0)
			make.bottom.equalTo(-8.0)
		}
		
		userNameLabel.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.trailing.equalTo(-16.0)
			make.leading.equalTo(profileImageView.snp.trailing).offset(10.0)
		}
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
