//
//  AppIconCell.swift
//  GitTime
//
//  Created by Kanz on 2020/10/28.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class AppIconCell: BaseTableViewCell, ReactorKit.View {
    
    typealias Reactor = AppIconCellReactor
        
    // MARK: Properties
    
    // MARK: UI Views
	private let iconImageView = UIImageView().then {
		$0.layer.cornerRadius = 8.0
		$0.layer.masksToBounds = true
	}
	
	private let titleLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 16.0)
		$0.textColor = .title
	}
    
    // MARK: - Initializing
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.backgroundColor = .secondarySystemGroupedBackground
		self.contentView.backgroundColor = .secondarySystemGroupedBackground
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
		self.contentView.addSubview(iconImageView)
		self.contentView.addSubview(titleLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
	
		iconImageView.snp.makeConstraints { make in
			make.leading.equalTo(16.0)
			make.width.height.equalTo(50.0)
			make.centerY.equalToSuperview()
		}
		
		titleLabel.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.trailing.equalTo(-16.0)
			make.leading.equalTo(iconImageView.snp.trailing).offset(10.0)
		}
    }
    
    // MARK: - Binding
    func bind(reactor: AppIconCellReactor) {
		
		reactor.state.map { $0.icon.imageName }
			.map { UIImage(named: $0) }
			.bind(to: self.iconImageView.rx.image)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.icon.title }
			.bind(to: self.titleLabel.rx.text)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { ($0.selectedIcon, $0.icon.plistIconName) }
			.subscribe(onNext: { [weak self] tuple in
				guard let self = self else { return }
				self.accessoryType = (tuple.0 == tuple.1) ? .checkmark : .none
			}).disposed(by: self.disposeBag)
    }
}
