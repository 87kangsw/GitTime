//
//  LanguageCell.swift
//  GitTime
//
//  Created by Kanz on 2021/02/10.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class LanguageCell: BaseTableViewCell, ReactorKit.View {
    
    typealias Reactor = LanguageCellReactor
        
    // MARK: Properties
    
    // MARK: UI Views
    private let languageLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 14.0)
        $0.text = "Swift"
		$0.textColor = .title
    }

    private let colorView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.backgroundColor = .red
		$0.cornerRadius(5.0)
    }

    let favoriteButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.setImage(UIImage(named: "favorite_empty"), for: .normal)
		$0.setImage(UIImage(named: "favorite_fill"), for: .selected)
    }

    let languageButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
    }

    // MARK: - Initializing
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - UI Setup
    override func addViews() {
        super.addViews()
        
		self.contentView.addSubview(languageLabel)
		self.contentView.addSubview(colorView)
		self.contentView.addSubview(favoriteButton)
		self.contentView.addSubview(languageButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
		languageLabel.snp.makeConstraints { make in
			make.leading.equalTo(16.0)
			make.top.bottom.equalToSuperview()
		}
		
		favoriteButton.snp.makeConstraints { make in
			make.width.height.equalTo(25.0)
			make.centerY.equalToSuperview()
			make.trailing.equalTo(-16.0)
		}
		
		colorView.snp.makeConstraints { make in
			make.width.height.equalTo(10.0)
			make.leading.equalTo(languageLabel.snp.trailing).offset(6.0)
			make.trailing.lessThanOrEqualTo(favoriteButton.snp.leading).offset(-8.0)
			make.centerY.equalToSuperview()
		}
		
		languageButton.snp.makeConstraints { make in
			make.leading.equalTo(languageLabel.snp.leading)
			make.top.bottom.equalToSuperview()
			make.trailing.equalTo(favoriteButton.snp.leading)
		}
    }
    
    // MARK: - Binding
    func bind(reactor: LanguageCellReactor) {
		reactor.state
			.subscribe(onNext: { [weak self] state in
				guard let self = self else { return }
				self.updateUI(state)
			}).disposed(by: self.disposeBag)
		
		reactor.state.map { $0.isFavorite }
			.bind(to: favoriteButton.rx.isSelected)
			.disposed(by: self.disposeBag)
    }
	
	fileprivate func updateUI(_ state: Reactor.State) {
		
		let languageName = state.language.name
		languageLabel.text = languageName
		languageLabel.font = state.language == GithubLanguage.allLanguage ?
			.boldSystemFont(ofSize: 15.0) : .systemFont(ofSize: 14.0)
		
		let colorName = state.language.color
		if !colorName.isEmpty {
			let color = UIColor(hexString: colorName)
			colorView.backgroundColor = color
		} else {
			colorView.backgroundColor = .clear
		}
		
		favoriteButton.isHidden = state.language == GithubLanguage.allLanguage
	}
	
}

// MARK: - Reactive Extension
extension Reactive where Base: LanguageCell {
	var favoriteTapped: Observable<GithubLanguage> {
		return base.favoriteButton.rx.tap
			.map { self.base.reactor?.currentState.language }
			.filterNil()
	}
	
	var languageTapped: ControlEvent<Void> {
		return base.languageButton.rx.tap
	}
}
