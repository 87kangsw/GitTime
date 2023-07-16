//
//  ActivityContributionView.swift
//  GitTime
//
//  Created by Kanz on 17/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

class ActivityContributionView: UIView, View {
    
    typealias Reactor = ActivityContributionViewReactor
    
    private struct Metric {
        static let cellSize: CGFloat = 8.0
        static let spacing: CGFloat = 2.0
    }
    
	enum Reusable {
		static let contributionCell = ReusableCell<ContributionCell>()
	}
	
    // MARK: - UI
    private let contributionCountLabel: UILabel = {
        let label = UILabel()
        return label
    }()
	
	private let flowLayout = UICollectionViewFlowLayout().then {
		$0.estimatedItemSize = CGSize(width: 10.0, height: 10.0)
		$0.scrollDirection = .horizontal
		$0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		$0.minimumLineSpacing = 2.0
		$0.minimumInteritemSpacing = 2.0
		$0.itemSize = CGSize(width: 5.0, height: 5.0)
	}
	
	lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
		$0.backgroundColor = .background
		$0.showsVerticalScrollIndicator = false
		$0.register(Reusable.contributionCell)
	}
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var layoutSubViewsFirstTime: Bool = true
    
    // MARK: - View Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contributionCountLabel)
        self.addSubview(collectionView)
        
        contributionCountLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(16.0)
            make.trailing.equalTo(-16.0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contributionCountLabel.snp.bottom).offset(8.0)
            make.leading.equalTo(16.0)
            make.trailing.bottom.equalTo(-16.0)
//            make.height.equalTo(47.0) // (5 * 7) + (2 * 6)
            make.height.equalTo((Metric.cellSize * 7) + (Metric.spacing * 6))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if layoutSubViewsFirstTime, collectionView.contentSize.width > 0.0 {
            layoutSubViewsFirstTime = false
            let offSet = collectionView.contentSize.width - collectionView.frame.width
            self.collectionView.setContentOffset(CGPoint(x: offSet, y: 0.0), animated: false)
        }
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        let count = state.contributionInfo.count
        contributionCountLabel.text = "\(count) contributions in the last year"
    }
    
    func bind(reactor: Reactor) {
        
        // State
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
        
		let factory = dataSourceFactory()
        reactor.state.map { $0.sections }
            .bind(to: collectionView.rx.items(dataSource: factory))
            .disposed(by: self.disposeBag)
        
		collectionView.rx.observe(CGSize.self, "contentSize")
			.filterNil()
			.filter { $0.width > 0.0 }
			.take(1)
			.subscribe(onNext: { [weak self] contentSize in
				guard let self = self else { return }
				let offSet = self.collectionView.contentSize.width - self.collectionView.frame.width
				self.collectionView.setContentOffset(CGPoint(x: offSet, y: 0.0), animated: false)
			}).disposed(by: self.disposeBag)
		/*
		collectionView.rx.itemSelected(dataSource: factory)
			.subscribe { sectionItem in
				switch sectionItem {
				case .contribution(let cellReactor):
					log.debug(cellReactor.currentState)
				}
			}
			.disposed(by: self.disposeBag)
		*/
		
        // View
        self.collectionView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
    }
	
	private func dataSourceFactory() -> RxCollectionViewSectionedReloadDataSource<ContributionSection> {
		return .init { dataSource, collectionView, indexPath, sectionItem in
			switch sectionItem {
			case .contribution(let reactor):
				let cell = collectionView.dequeue(Reusable.contributionCell, for: indexPath)
				cell.reactor = reactor
				return cell
			}
		}
	}
}

extension ActivityContributionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Metric.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Metric.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Metric.cellSize, height: Metric.cellSize)
    }
}
