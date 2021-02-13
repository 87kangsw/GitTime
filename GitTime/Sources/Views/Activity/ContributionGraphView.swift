//
//  ContributionGraphView.swift
//  GitTime
//
//  Created Kanz on 2020/11/04.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import Then

final class ContributionGraphView: BaseView, ReactorKit.View {
    
    typealias Reactor = ContributionGraphViewReactor
    
	private struct Metric {
		static let cellSize: CGFloat = 8.0
		static let spacing: CGFloat = 2.0
	}
	
	enum Reusable {
		static let contributionCell = ReusableCell<ContributionCell>()
	}
	
	// MARK: UI Views
	lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
		$0.backgroundColor = .background
		$0.showsVerticalScrollIndicator = false
		$0.showsHorizontalScrollIndicator = false
		$0.register(Reusable.contributionCell)
		$0.backgroundColor = .secondarySystemGroupedBackground
	}
	
    // MARK: Properties
	private let flowLayout = UICollectionViewFlowLayout().then {
//		$0.estimatedItemSize = CGSize(width: 10.0, height: 10.0)
		$0.scrollDirection = .horizontal
		$0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		$0.minimumLineSpacing = Metric.spacing
		$0.minimumInteritemSpacing = Metric.spacing
		$0.itemSize = CGSize(width: Metric.cellSize, height: Metric.cellSize)
	}
	
	static var dataSource: RxCollectionViewSectionedReloadDataSource<ContributionSection> {
		return .init(configureCell: { (datasource, collectionView, indexPath, sectionItem) -> UICollectionViewCell in
			switch sectionItem {
			case .contribution(let reactor):
//                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ContributionCell.self)
				let cell = collectionView.dequeue(Reusable.contributionCell, for: indexPath)
				cell.reactor = reactor
				return cell
			}
		})
	}
	private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<ContributionSection> = type(of: self).dataSource
	
	
    // MARK: - Initializing
    override init() {
        super.init()
    }
    
    convenience init(reactor: ContributionGraphViewReactor) {
        defer { self.reactor = reactor }
        self.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    override func addViews() {
        super.addViews()
		self.addSubview(collectionView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
    }
    
    // MARK: - Binding
    func bind(reactor: ContributionGraphViewReactor) {
		
		reactor.state.map { $0.sections }
//			.debug("sections")
			.do(onNext: { [weak self] contributions in
				guard let self = self, contributions.isNotEmpty else { return }
				let offSet = self.collectionView.contentSize.width - self.collectionView.frame.width
				self.collectionView.setContentOffset(CGPoint(x: offSet, y: 0.0), animated: false)
			})
			.bind(to: collectionView.rx.items(dataSource: dataSource))
			.disposed(by: self.disposeBag)
		
		// View
		self.collectionView.rx.setDelegate(self)
			.disposed(by: self.disposeBag)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ContributionGraphView: UICollectionViewDelegateFlowLayout {
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
