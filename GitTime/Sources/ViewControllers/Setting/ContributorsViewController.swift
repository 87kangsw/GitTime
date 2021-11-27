//
//  ContributorsViewController.swift
//  GitTime
//
//  Created Kanz on 2020/10/27.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import ReusableKit

final class ContributorsViewController: BaseViewController, ReactorKit.View {
    
    typealias Reactor = ContributorsViewReactor
    
    private struct Reusable {
         static let contributorCell = ReusableCell<ContributorCell>()
    }
    
	// MARK: Views
	private let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
		$0.estimatedRowHeight = 56.0
		$0.rowHeight = UITableView.automaticDimension
		$0.register(Reusable.contributorCell)
		$0.backgroundColor = .systemGroupedBackground
	}
	private let loadingIndicator = UIActivityIndicatorView().then {
		$0.hidesWhenStopped = true
		$0.color = .invertBackground
	}
	
    // MARK: Properties
    
    // MARK: Initializing
    init(reactor: ContributorsViewReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Contributors"
    }
    
    override func addViews() {
        super.addViews()
		self.view.addSubview(tableView)
		self.view.addSubview(loadingIndicator)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
		
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		loadingIndicator.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
    }
    
    // MARK: Binding
    func bind(reactor: ContributorsViewReactor) {
        
		self.rx.viewDidLoad
			.map { Reactor.Action.firstLoad }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.isLoading }
			.distinctUntilChanged()
			.bind(to: loadingIndicator.rx.isAnimating )
			.disposed(by: self.disposeBag)
		
		let dataSource = self.dataSource()
		reactor.state.map { $0.sections }
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: self.disposeBag)
		
		tableView.rx.itemSelected(dataSource: dataSource)
			.subscribe(onNext: { [weak self] sectionItem in
				guard let self = self else { return }
				switch sectionItem {
				case .contributor(let cellReactor):
					let user = cellReactor.currentState.user
					self.pushSFSafariWeb(urlString: user.url)
				}
			}).disposed(by: self.disposeBag)
		
		tableView.rx.itemSelected
			.subscribe(onNext: { [weak tableView] indexPath in
				tableView?.deselectRow(at: indexPath, animated: true)
			}).disposed(by: self.disposeBag)
    }
	
	private func dataSource() -> RxTableViewSectionedReloadDataSource<ContributorSection> {
		return .init(configureCell: { (_, tableView, indexPath, sectionItem) -> UITableViewCell in
			switch sectionItem {
			case .contributor(let cellReactor):
				let cell = tableView.dequeue(Reusable.contributorCell, for: indexPath)
				cell.reactor = cellReactor
				return cell
			}
		})
	}
	
}
