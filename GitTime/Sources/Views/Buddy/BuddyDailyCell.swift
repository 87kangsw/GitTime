//
//  BuddyDailyCell.swift
//  GitTime
//
//  Created by Kanz on 2020/11/04.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class BuddyDailyCell: BaseTableViewCell, ReactorKit.View {
    
    typealias Reactor = BuddyDailyCellReactor
     
    // MARK: Properties
    
    // MARK: UI Views
	private let profileImageView = UIImageView().then {
		$0.image = UIImage(systemName: "person.circle")
		$0.layer.cornerRadius = 8.0
		$0.layer.masksToBounds = true
		$0.contentMode = .scaleAspectFill
	}
	
	private let nameLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 14.0)
		$0.textColor = .title
	}
	
	private let contributionLabel = UILabel().then {
		$0.text = 10.toContributionIcon()
		$0.textAlignment = .center
		$0.font = .systemFont(ofSize: 16.0)
	}
	
    // MARK: - Initializing
	override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.accessoryType = .none
		self.backgroundColor = .secondarySystemGroupedBackground
		self.contentView.backgroundColor = .secondarySystemGroupedBackground
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func prepareForReuse() {
        super.prepareForReuse()
		profileImageView.image = nil
		nameLabel.text = ""
		contributionLabel.text = ""
    }
    
    // MARK: - UI Setup
    override func addViews() {
        super.addViews()
		self.contentView.addSubview(profileImageView)
		self.contentView.addSubview(nameLabel)
		self.contentView.addSubview(contributionLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
		profileImageView.snp.makeConstraints { make in
			make.leading.equalTo(16.0)
			make.width.height.equalTo(40.0)
			make.top.equalTo(8.0)
			make.bottom.equalTo(-8.0)
		}
		
		contributionLabel.snp.makeConstraints { make in
			make.trailing.equalTo(-16.0)
			make.top.bottom.equalToSuperview()
		}
		
		nameLabel.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.leading.equalTo(profileImageView.snp.trailing).offset(10.0)
			make.trailing.equalTo(contributionLabel.snp.leading).offset(-8.0)
		}
    }
	
	// MARK: - Binding
	func bind(reactor: BuddyDailyCellReactor) {
		
		reactor.state.map { $0.contributionInfo }
			.subscribe(onNext: { [weak self] object in
				guard let self = self else { return }

				if let url = URL(string: object.profileImageURL) {
					self.profileImageView.kf.setImage(with: url)
				} else {
					self.profileImageView.image = UIImage(systemName: "person.circle")
				}
				
				self.nameLabel.text = object.additionalName
				
				if let count = object.contributions.last?.contribution {
					self.contributionLabel.text = "\(count.toContributionIcon())  \(count)"
				} else {
					self.contributionLabel.text = "\(0.toContributionIcon()) \(0)"
				}
				
			}).disposed(by: self.disposeBag)
	}
}
