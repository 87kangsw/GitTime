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

final class TrendingDeveloperCell: BaseTableViewCell, ReactorKit.View {
	
	typealias Reactor = TrendingDeveloperCellReactor
	
	// MARK: - UI
	private let rankLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 10.0)
		$0.textColor = .title
	}
	
	private let profileImageView = UIImageView().then {
		$0.translatesAutoresizingMaskIntoConstraints = true
		$0.cornerRadius(8.0)
	}
	
	private let authorInfoStackView = UIStackView().then {
		$0.translatesAutoresizingMaskIntoConstraints = true
		$0.axis = .vertical
	}
	
	private let nameLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .boldSystemFont(ofSize: 14.0)
		$0.textColor = .title
	}
	
	private let userNameLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 12.0)
		$0.textColor = .title
	}
	
    private let repoIconImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.image = UIImage(named: "create_repo")
    }

	private let repoNameLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .boldSystemFont(ofSize: 13.0)
		$0.textColor = .title
	}
	
	private let repoDescLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 12.0)
		$0.textColor = .title
		$0.numberOfLines = 0
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
		
	}
	
	// MARK: - UI Setup
	override func addViews() {
		super.addViews()
		
		self.contentView.addSubview(rankLabel)
		self.contentView.addSubview(profileImageView)
		self.contentView.addSubview(authorInfoStackView)
		
		authorInfoStackView.addArrangedSubview(nameLabel)
		authorInfoStackView.addArrangedSubview(userNameLabel)
		
		self.contentView.addSubview(repoIconImageView)
		self.contentView.addSubview(repoNameLabel)
		self.contentView.addSubview(repoDescLabel)
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		rankLabel.snp.makeConstraints { make in
			make.top.equalTo(15.0)
			make.leading.equalTo(8.0)
		}
		
		profileImageView.snp.makeConstraints { make in
			make.top.equalTo(12.0)
			make.leading.equalTo(rankLabel.snp.trailing).offset(12.0)
			make.width.height.equalTo(40.0)
		}
		
		authorInfoStackView.snp.makeConstraints { make in
			make.centerY.equalTo(profileImageView.snp.centerY)
			make.leading.equalTo(profileImageView.snp.trailing).offset(10.0)
			make.trailing.lessThanOrEqualTo(-12.0)
		}
		
		repoIconImageView.snp.makeConstraints { make in
			make.top.equalTo(profileImageView.snp.bottom).offset(10.0)
			make.width.height.equalTo(16.0)
			make.leading.equalTo(profileImageView.snp.leading)
		}
		
		repoNameLabel.snp.makeConstraints { make in
			make.leading.equalTo(repoIconImageView.snp.trailing).offset(6.0)
			make.centerY.equalTo(repoIconImageView.snp.centerY)
		}
		
		repoDescLabel.snp.makeConstraints { make in
			make.leading.equalTo(profileImageView.snp.leading)
			make.top.equalTo(repoIconImageView.snp.bottom).offset(8.0)
			make.trailing.lessThanOrEqualTo(-10.0)
			make.bottom.equalTo(-12.0)
			make.width.equalToSuperview().multipliedBy(0.8)
		}
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
		
		repoNameLabel.isHidden = false
		repoDescLabel.isHidden = false
		repoIconImageView.isHidden = false
		
		let repoName = state.repoName
		if repoName.isNotEmpty == true {
			repoNameLabel.text = repoName
			if let repoDesc = state.repoDescription {
				repoDescLabel.text = repoDesc
			} else {
				repoDescLabel.isHidden = true
			}
		} else {
			repoNameLabel.isHidden = true
			repoDescLabel.isHidden = true
			repoIconImageView.isHidden = true
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
