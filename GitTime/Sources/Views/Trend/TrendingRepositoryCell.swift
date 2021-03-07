//
//  TrendingRepositoryCell.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class TrendingRepositoryCell: BaseTableViewCell, ReactorKit.View {
    
    typealias Reactor = TrendingRepositoryCellReactor
    
    // MARK: - UI
	private let repoIconImageView = UIImageView().then {
		$0.image = UIImage(named: "create_repo")
	}
	
	private let topStackView = UIStackView().then {
		$0.axis = .horizontal
		$0.spacing = 4.0
	}
	
	private let authorNameLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 13.0)
		$0.textColor = .title
		$0.text = "87kangsw"
	}
	
    private let slashLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 13.0)
        $0.text = "/"
		$0.textColor = .title
    }

	private let repoNameLabel = UILabel().then {
		$0.font = .boldSystemFont(ofSize: 13.0)
		$0.textColor = .title
		$0.text = "GitTime"
	}
	
	private let descriptionLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 12.0)
		$0.numberOfLines = 0
	}
	
    private let starImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.image = UIImage(named: "starred")
    }

    private let totalStarLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 13.0)
        $0.text = "5.5K"
		$0.textColor = .title
		$0.textAlignment = .right
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let forkImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.image = UIImage(named: "forked")
    }
	
    private let totalForkLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 13.0)
        $0.text = "5.5K"
		$0.textColor = .title
		$0.textAlignment = .right
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let languageNameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 12.0)
		$0.text = "Swift"
		$0.textColor = .title
    }
	
    private let languageColorView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.layer.cornerRadius = 5.0 / 2
		$0.layer.masksToBounds = true
		$0.backgroundColor = .red
    }
	
    private let builtByLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 12.0)
		$0.text = "Built by"
		$0.textColor = .title
    }

    private let contributorStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.axis = .horizontal
		$0.spacing = 5.0
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
		languageColorView.backgroundColor = .clear
		self.languageNameLabel.text = ""
	}
	
	// MARK: - UI Setup
	
	override func addViews() {
		super.addViews()

		self.contentView.addSubview(repoIconImageView)
		
		self.contentView.addSubview(topStackView)
		topStackView.addArrangedSubview(authorNameLabel)
		topStackView.addArrangedSubview(slashLabel)
		topStackView.addArrangedSubview(repoNameLabel)
		
		self.contentView.addSubview(totalStarLabel)
		self.contentView.addSubview(starImageView)
		
		self.contentView.addSubview(totalForkLabel)
		self.contentView.addSubview(forkImageView)
		
		self.contentView.addSubview(languageNameLabel)
		self.contentView.addSubview(languageColorView)
		
		self.contentView.addSubview(builtByLabel)
		self.contentView.addSubview(contributorStackView)
		
		self.contentView.addSubview(descriptionLabel)
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		repoIconImageView.snp.makeConstraints { make in
			make.top.equalTo(12.0)
			make.leading.equalTo(12.0)
			make.width.height.equalTo(16.0)
		}
		
		totalStarLabel.snp.makeConstraints { make in
			make.top.equalTo(12.0)
			make.trailing.equalTo(-12.0)
		}
		
		starImageView.snp.makeConstraints { make in
			make.centerY.equalTo(totalStarLabel.snp.centerY)
			make.trailing.equalTo(totalStarLabel.snp.leading).offset(-4.0)
			make.width.height.equalTo(14.0)
		}
		
		totalForkLabel.snp.makeConstraints { make in
			make.top.equalTo(totalStarLabel.snp.bottom).offset(10.0)
			make.trailing.equalTo(-12.0)
//			make.width.equalTo(totalStarLabel.snp.width)
		}
		
		forkImageView.snp.makeConstraints { make in
			make.centerY.equalTo(totalForkLabel.snp.centerY)
			make.trailing.equalTo(totalForkLabel.snp.leading).offset(-4.0)
			make.width.height.equalTo(14.0)
		}
		
		topStackView.snp.makeConstraints { make in
			make.top.equalTo(12.0)
			make.leading.equalTo(repoIconImageView.snp.trailing).offset(8.0)
			make.trailing.lessThanOrEqualTo(starImageView.snp.leading).offset(-12.0)
		}
		
		languageNameLabel.snp.makeConstraints { make in
			make.bottom.equalTo(-16.0)
			make.trailing.equalTo(-12.0)
			make.top.greaterThanOrEqualTo(totalForkLabel.snp.bottom).offset(10.0)
		}
		
		languageColorView.snp.makeConstraints { make in
			make.width.height.equalTo(5.0)
			make.trailing.equalTo(languageNameLabel.snp.leading).offset(-5.0)
			make.centerY.equalTo(languageNameLabel.snp.centerY)
		}
		
		builtByLabel.snp.makeConstraints { make in
			make.leading.equalTo(12.0)
//			make.bottom.equalTo(-16.0)
			make.centerY.equalTo(contributorStackView.snp.centerY)
		}
		
		contributorStackView.snp.makeConstraints { make in
			make.bottom.equalTo(-16.0)
			make.leading.equalTo(builtByLabel.snp.trailing).offset(4.0)
			make.trailing.lessThanOrEqualTo(languageColorView.snp.leading).offset(-8.0)
			make.height.equalTo(18.0)
		}
		
		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(topStackView.snp.bottom).offset(8.0)
			make.leading.equalTo(12.0)
			make.bottom.equalTo(builtByLabel.snp.top).offset(-8.0)
			make.trailing.lessThanOrEqualTo(starImageView.snp.leading).offset(-12.0)
		}
	}
    
    func bind(reactor: Reactor) {
        
		reactor.state.map { $0.author }
			.bind(to: authorNameLabel.rx.text)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.repoName }
			.bind(to: repoNameLabel.rx.text)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.totalStars }
			.map { $0.formatUsingAbbrevation() }
			.bind(to: totalStarLabel.rx.text)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.totalForks }
			.map { $0.formatUsingAbbrevation() }
			.bind(to: totalForkLabel.rx.text)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.language }
			.bind(to: languageNameLabel.rx.text)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.languageColor }
			.filterNil()
			.filter { $0.isNotEmpty }
			.map { UIColor(hexString: $0) }
			.bind(to: languageColorView.rx.backgroundColor)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.description }
			.bind(to: descriptionLabel.rx.text)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.contributors }
			.subscribe(onNext: { [weak self] contributors in
				guard let self = self else { return }
				self.contributorStackView.subviews.forEach { $0.removeFromSuperview() }
				
				for contributor in contributors {
					let urlString = contributor.profileURL
					guard let url = URL(string: urlString) else { continue }
					let profileImageView = UIImageView()
					profileImageView.widthAnchor.constraint(equalToConstant: 18.0).isActive = true
					profileImageView.heightAnchor.constraint(equalToConstant: 18.0).isActive = true
					profileImageView.layer.cornerRadius = 9.0
					profileImageView.layer.masksToBounds = true
					profileImageView.kf.setImage(with: url)
					self.contributorStackView.addArrangedSubview(profileImageView)
				}
				
			}).disposed(by: self.disposeBag)
    }
}
