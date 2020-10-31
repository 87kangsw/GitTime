//
//  ActivityItemCell.swift
//  GitTime
//
//  Created by Kanz on 10/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class ActivityItemCell: BaseTableViewCell, ReactorKit.View {
    
    typealias Reactor = ActivityItemCellReactor

    // MARK: - UI
	private let eventIconImageView = UIImageView()
	private let repositoryLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = .boldSystemFont(ofSize: 13.0)
		$0.textColor = .title
		$0.text = "87kangsw/GitTime"
	}
	
	private let titleLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = .systemFont(ofSize: 12.0)
		$0.textColor = .subTitle
		$0.text = "Version 2.0.0 Released!!"
		$0.numberOfLines = 2
	}
	
	private let summaryLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = .systemFont(ofSize: 12.0)
		$0.textColor = .subTitle
		$0.text = "v2.0.0 Released"
		$0.numberOfLines = 0
	}
	
	private let dateLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = .systemFont(ofSize: 12.0)
		$0.textColor = .subTitle
		$0.text = "1h"
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
	}
	
	private let underLine = UIView().then {
		$0.backgroundColor = .underLine
	}
	
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
		eventIconImageView.image = nil
		repositoryLabel.text = ""
		titleLabel.text = ""
		summaryLabel.text = ""
		dateLabel.text = ""
	}
	
	// MARK: - UI Setup
	
	override func addViews() {
		super.addViews()
		
		self.contentView.addSubview(eventIconImageView)
		self.contentView.addSubview(repositoryLabel)
		self.contentView.addSubview(titleLabel)
		self.contentView.addSubview(summaryLabel)
		self.contentView.addSubview(dateLabel)
		self.contentView.addSubview(underLine)
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		eventIconImageView.snp.makeConstraints { make in
			make.top.equalTo(12.0)
			make.leading.equalTo(12.0)
			make.width.height.equalTo(30.0)
		}
		
		dateLabel.snp.makeConstraints { make in
			make.top.equalTo(12.0)
			make.trailing.equalTo(-12.0)
		}
		
		repositoryLabel.snp.makeConstraints { make in
			make.top.equalTo(12.0)
			make.leading.equalTo(eventIconImageView.snp.trailing).offset(12.0)
//			make.trailing.equalTo(dateLabel.snp.leading).offset(-10.0)
            make.trailing.lessThanOrEqualTo(dateLabel.snp.leading).offset(-10.0)
		}
		
		titleLabel.snp.makeConstraints { make in
			make.top.equalTo(repositoryLabel.snp.bottom).offset(5.0)
			make.leading.equalTo(eventIconImageView.snp.trailing).offset(12.0)
//			make.trailing.equalTo(dateLabel.snp.leading).offset(-10.0)
            make.trailing.lessThanOrEqualTo(dateLabel.snp.leading).offset(-10.0)
		}
		
		summaryLabel.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(5.0)
			make.leading.equalTo(eventIconImageView.snp.trailing).offset(12.0)
//			make.trailing.equalTo(dateLabel.snp.leading).offset(-10.0)
            make.trailing.lessThanOrEqualTo(dateLabel.snp.leading).offset(-10.0)
			make.bottom.equalTo(-12.0)
		}
		
		underLine.snp.makeConstraints { make in
			make.trailing.equalToSuperview()
			make.leading.equalTo(eventIconImageView.snp.trailing).offset(12.0)
			make.height.equalTo(0.5)
			make.bottom.equalToSuperview()
		}
	}
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let iconImage = state.event.eventIconImage
        eventIconImageView.image = iconImage
        
        let actor = state.event.actor.name
        let eventMessage = state.event.eventMessage ?? ""
        titleLabel.text = "\(actor) \(eventMessage)"
        
		let repository = state.event.repositoryURL ?? state.event.repo.name
        repositoryLabel.text = repository
        
        let description = state.event.description
        summaryLabel.text = description ?? ""
        
        let date = state.event.createdAt
        let dateString = date.timeAgo()
        dateLabel.text = dateString
    }
    
    func bind(reactor: Reactor) {
        
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
