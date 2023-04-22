//
//  BuddyWeeklyCell.swift
//  GitTime
//
//  Created by Kanz on 2020/11/16.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class BuddyYearlyCell: BaseTableViewCell, ReactorKit.View {
    
    typealias Reactor = BuddyYearlyCellReactor
    
	private struct Metric {
		static let cellSize: CGFloat = 8.0
		static let spacing: CGFloat = 2.0
	}
	
	// MARK: UI Views
	private let profileImageView = UIImageView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.image = UIImage(systemName: "person.circle")
		$0.layer.cornerRadius = 8.0
		$0.layer.masksToBounds = true
		$0.contentMode = .scaleAspectFill
	}
	
	private let nameLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = .systemFont(ofSize: 14.0)
		$0.textColor = .title
	}
	
	private let graphView = ContributionGraphView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.backgroundColor = .secondarySystemGroupedBackground
	}
	
	private let updateDateLabel = UILabel().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.font = .systemFont(ofSize: 12.0)
		$0.textColor = .lightGray
		$0.textAlignment = .right
		$0.text = "2020-12-03 13:50:30"
	}
	
    // MARK: Properties
	var layoutSubViewsFirstTime: Bool = true
	
    // MARK: - Initializing
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if layoutSubViewsFirstTime, graphView.collectionView.contentSize.width > 0.0 {
			layoutSubViewsFirstTime = false
			let offSet = graphView.collectionView.contentSize.width - graphView.collectionView.frame.width
			graphView.collectionView.setContentOffset(CGPoint(x: offSet, y: 0.0), animated: false)
		}
	}
    
    // MARK: - UI Setup
    override func addViews() {
        super.addViews()
		self.contentView.addSubview(profileImageView)
		self.contentView.addSubview(nameLabel)
		self.contentView.addSubview(graphView)
		self.contentView.addSubview(updateDateLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
		profileImageView.snp.makeConstraints { make in
			make.leading.equalTo(12.0)
			make.width.height.equalTo(30.0)
			make.top.equalTo(8.0)
		}
		
		nameLabel.snp.makeConstraints { make in
			make.leading.equalTo(profileImageView.snp.trailing).offset(10.0)
			make.trailing.equalToSuperview().offset(-8.0)
			make.centerY.equalTo(profileImageView.snp.centerY)
		}
		
		graphView.snp.makeConstraints { make in
			make.top.equalTo(profileImageView.snp.bottom).offset(12.0)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo((Metric.cellSize * 7) + (Metric.spacing * 6))
		}
		
		updateDateLabel.snp.makeConstraints { make in
			make.leading.equalTo(12.0)
			make.trailing.equalTo(-12.0)
			make.top.equalTo(graphView.snp.bottom).offset(5.0)
			make.bottom.equalTo(-6.0)
		}
    }
    
    // MARK: - Binding
    func bind(reactor: BuddyYearlyCellReactor) {

		bindGraphViewReactor(reactor: reactor)
		
		reactor.state.map { $0.contributionInfo }
			.subscribe(onNext: { [weak self] object in
				guard let self = self else { return }
				if let url = URL(string: object.profileImageURL) {
					self.profileImageView.kf.setImage(with: url)
				} else {
					self.profileImageView.image = UIImage(systemName: "person.circle")
				}
				self.nameLabel.text = object.additionalName
			}).disposed(by: self.disposeBag)
		
		reactor.state.map { $0.contributionInfo.updatedAt }
			.map { $0 ?? reactor.currentState.contributionInfo.createdAt }
			.subscribe(onNext: { [weak self] updatedAt in
				guard let self = self else { return }
				let updateDate = updatedAt.toString()
				self.updateDateLabel.text = "Last updated at \(updateDate)"
			}).disposed(by: self.disposeBag)
    }
	
	func bindGraphViewReactor(reactor: BuddyYearlyCellReactor) {
		graphView.reactor = reactor.graphReactor
	}
}
