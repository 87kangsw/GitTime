//
//  FollowViewController.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import SafariServices
import UIKit

import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxSwift

class FollowViewController: BaseViewController, ReactorKit.View {
	
	typealias Reactor = FollowViewReactor
	
	enum Reusable {
		static let followUserCell = ReusableCell<FollowUserCell>()
	}
	
	// MARK: - UI
	private let segmentControl = UISegmentedControl(items: FollowTypes.allCases.map { $0.segmentTitle }).then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.selectedSegmentIndex = 0
	}
	
	private let tableView = UITableView().then {
		$0.estimatedRowHeight = 60.0
		$0.rowHeight = UITableView.automaticDimension
		//		$0.backgroundColor = .background
		$0.separatorColor = .underLine
		$0.register(Reusable.followUserCell)
	}
	
	private let tableHeaderView = UIView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.backgroundColor = .background
		$0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50.0)
	}
	private let loadingIndicator = UIActivityIndicatorView().then {
		$0.hidesWhenStopped = true
		$0.color = .invertBackground
	}
	private let refreshControl = UIRefreshControl()
	private let close = UIBarButtonItem(title: "Close", style: .plain, target: nil, action: nil)
	
	// MARK: - Properties
	static var dataSource: RxTableViewSectionedReloadDataSource<FollowSection> {
		return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
			switch sectionItem {
			case .followUsers(let reactor):
				let cell = tableView.dequeue(Reusable.followUserCell, for: indexPath)
				cell.reactor = reactor
				return cell
			}
		})
	}
	private lazy var dataSource: RxTableViewSectionedReloadDataSource<FollowSection> = type(of: self).dataSource
	
	private let selectUserSubject = PublishSubject<User>()
	var selectedUser: Observable<User> {
		return selectUserSubject.asObservable()
	}
	
	// MARK: - Initializing
	init(reactor: Reactor) {
		defer { self.reactor = reactor }
		
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Follow"
		self.navigationItem.leftBarButtonItem = close
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		//		FollowTypes.allCases.enumerated().forEach { (index, type) in
		//			segmentControl.setTitle(type.segmentTitle, forSegmentAt: index)
		//		}
	}
	
	override func addViews() {
		super.addViews()
		
		self.view.addSubview(tableView)
		self.view.addSubview(loadingIndicator)
		tableHeaderView.addSubview(segmentControl)
		
		tableView.refreshControl = refreshControl
		tableView.tableHeaderView = tableHeaderView
		tableView.tableFooterView = UIView()
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		tableHeaderView.snp.makeConstraints { make in
			make.height.equalTo(50.0)
			make.width.equalTo(tableView.snp.width)
		}
		
		segmentControl.snp.makeConstraints { make in
			make.leading.equalTo(16.0)
			make.trailing.equalTo(-16.0)
			make.top.equalTo(8.0)
			make.bottom.equalTo(-8.0)
		}
		
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		loadingIndicator.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		
	}
	
	// MARK: - Configure
	func bind(reactor: Reactor) {
		
		// Action
		Observable.just(Void())
			.map { Reactor.Action.refresh }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		close.rx.tap
			.subscribe(onNext: { [weak self] _ in
				guard let self = self else { return }
				self.dismiss(animated: true, completion: nil)
			}).disposed(by: self.disposeBag)
		
		segmentControl.rx.controlEvent(.valueChanged)
			.map { _ in Reactor.Action.switchSegmentControl }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		refreshControl.rx.controlEvent(.valueChanged)
			.map { Reactor.Action.refresh }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		tableView.rx.reachedBottom
			.observeOn(MainScheduler.instance)
			.map { Reactor.Action.loadMore }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		// State
		reactor.state.map { $0.followSections }
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.isRefreshing }
			.distinctUntilChanged()
			.bind(to: refreshControl.rx.isRefreshing)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.isLoading }
			.distinctUntilChanged()
			.bind(to: loadingIndicator.rx.isAnimating )
			.disposed(by: self.disposeBag)
		
		// View
		tableView.rx.itemSelected(dataSource: dataSource)
			.subscribe(onNext: { [weak self] sectionItem in
				guard let self = self else { return }
				switch sectionItem {
				case .followUsers(let reactor):
					//                    self.pushSFSafariWeb(urlString: reactor.currentState.followUser.url)
					self.dismiss(animated: true, completion: { [weak self] in
						self?.selectUserSubject.onNext(reactor.currentState.followUser)
						self?.selectUserSubject.onCompleted()
					})
				}
			}).disposed(by: self.disposeBag)
		
		tableView.rx.itemSelected
			.subscribe(onNext: { [weak tableView] indexPath in
				tableView?.deselectRow(at: indexPath, animated: true)
			}).disposed(by: self.disposeBag)
		
	}
	
}
