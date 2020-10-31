//
//  ContributorCell.swift
//  GitTime
//
//  Created by Kanz on 2020/10/27.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class ContributorCell: BaseTableViewCell, ReactorKit.View {
    
    typealias Reactor = ContributorCellReactor
    
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
    
    // MARK: - Initializing
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.accessoryType = .disclosureIndicator
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
        
		self.contentView.addSubview(profileImageView)
		self.contentView.addSubview(nameLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
		profileImageView.snp.makeConstraints { make in
			make.leading.equalTo(16.0)
			make.width.height.equalTo(40.0)
			make.top.equalTo(8.0)
			make.bottom.equalTo(-8.0)
		}
		
		nameLabel.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.trailing.equalTo(-16.0)
			make.leading.equalTo(profileImageView.snp.trailing).offset(10.0)
		}
    }
    
    // MARK: - Binding
    func bind(reactor: ContributorCellReactor) {
        
		reactor.state.map { $0.user.name }
			.bind(to: self.nameLabel.rx.text)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.user.profileURL }
			.subscribe(onNext: { [weak self] urlString in
				guard let self = self, let url = URL(string: urlString) else { return }
				self.profileImageView.kf.setImage(with: url)
			}).disposed(by: self.disposeBag)
    }
}
