//
//  ActivityViewController.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import PanModal
import Pure
import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxSwift
import Then
import Toaster

class ActivityViewController: BaseViewController, ReactorKit.View {
	
	typealias Reactor = ActivityViewReactor
	
	enum Reusable {
		static let activityCell = ReusableCell<ActivityItemCell>()
		static let emptyTableViewCell = ReusableCell<EmptyTableViewCell>()
	}
	
	// MARK: - UI
	private var tableView = UITableView().then {
		$0.separatorStyle = .none
		$0.estimatedRowHeight = 100.0
		$0.rowHeight = UITableView.automaticDimension
		$0.backgroundColor = .background
		
		$0.register(Reusable.activityCell)
		$0.register(Reusable.emptyTableViewCell)
	}
	private var loadingIndicator = UIActivityIndicatorView().then {
		$0.hidesWhenStopped = true
		$0.style = .large
		$0.color = .invertBackground
	}
	private var contributionHeaderView = ActivityContributionView().then {
		$0.frame = .zero
	}
	private let refreshControl = UIRefreshControl()
	private let profileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30)).then {
		$0.setImage(UIImage(systemName: "person.circle"), for: .normal)
		$0.layer.cornerRadius = 30.0 / 2
		$0.layer.masksToBounds = true
		$0.backgroundColor = .white
		$0.imageView?.contentMode = .scaleAspectFit
	}
	lazy var rightBarButton = UIBarButtonItem(customView: profileButton)
	
	// MARK: - Properties
	static var dataSource: RxTableViewSectionedReloadDataSource<ActivitySection> {
		return .init(configureCell: { (_, tableView, indexPath, sectionItem) -> UITableViewCell in
			switch sectionItem {
			case .createEvent(let reactor),
				 .forkEvent(let reactor),
				 .issueCommentEvent(let reactor),
				 .issuesEvent(let reactor),
				 .pullRequestEvent(let reactor),
				 .pushEvent(let reactor),
				 .watchEvent(let reactor),
				 .releaseEvent(let reactor),
				 .pullRequestReviewCommentEvent(let reactor),
				 .publicEvent(let reactor):
				let cell = tableView.dequeue(Reusable.activityCell, for: indexPath)
				cell.reactor = reactor
				return cell
			case .empty(let reactor):
				let cell = tableView.dequeue(Reusable.emptyTableViewCell, for: indexPath)
				cell.selectionStyle = .none
				cell.reactor = reactor
				return cell
			}
		})
	}
	private lazy var dataSource: RxTableViewSectionedReloadDataSource<ActivitySection> = type(of: self).dataSource
	
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
		self.navigationItem.rightBarButtonItem = rightBarButton
		addNotifications()
	}
	
	override func addViews() {
		super.addViews()
		
		self.view.addSubview(tableView)
		self.view.addSubview(loadingIndicator)
		
		tableView.refreshControl = refreshControl
		tableView.tableHeaderView = self.contributionHeaderView
		tableView.tableFooterView = UIView()
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		loadingIndicator.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		
		let width: CGFloat = UIScreen.main.bounds.width
		contributionHeaderView.snp.makeConstraints { make in
			make.width.equalTo(width)
		}
	}
	
	// MARK: - Configure
	func bind(reactor: Reactor) {
		
		// Action
		Observable.just(Void())
			.do(onNext: { _ in
				Toast(text: "Contribution crawling server starting..", duration: Delay.short).show()
			})
			.map { _ in Reactor.Action.firstLoad }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		tableView.rx.reachedBottom
			.observe(on: MainScheduler.instance)
			.map { Reactor.Action.loadMoreActivities }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		refreshControl.rx.controlEvent(.valueChanged)
			.map { Reactor.Action.refresh }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		profileButton.rx.tap
			.subscribe(onNext: { [weak self] _ in
				guard let self = self, let url = reactor.currentState.user?.url else { return }
				self.pushSFSafariWeb(urlString: url)
			}).disposed(by: self.disposeBag)
		
		// State
		reactor.state.map { $0.isLoading }
			.bind(to: loadingIndicator.rx.isAnimating)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.isRefreshing }
			.distinctUntilChanged()
			.bind(to: refreshControl.rx.isRefreshing)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.sectionItems }
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.contributionInfo }
			.filterNil()
			.take(1)
			.subscribe(onNext: { [weak self] info in
				guard let self = self else { return }
				let reactor = ActivityContributionViewReactor(contributionInfo: info)
				self.contributionHeaderView.reactor = reactor
			}).disposed(by: self.disposeBag)

		reactor.state.map { $0.currentProfileImage }
		.map { profileImage -> UIImage? in
			if let profileImage = profileImage {
				return profileImage.resized(to: CGSize(width: 30.0, height: 30.0))
			} else {
				return UIImage(systemName: "person.circle")
			}
		}
		.bind(to: profileButton.rx.image(for: .normal))
		.disposed(by: self.disposeBag)
		
		// View
		tableView.rx.itemSelected(dataSource: dataSource)
			.subscribe(onNext: { [weak self] sectionItem in
				guard let self = self else { return }
				switch sectionItem {
				case .empty:
					break
				case .createEvent(let reactor),
					 .forkEvent(let reactor),
					 .issueCommentEvent(let reactor),
					 .issuesEvent(let reactor),
					 .pullRequestEvent(let reactor),
					 .pushEvent(let reactor),
					 .watchEvent(let reactor),
					 .releaseEvent(let reactor),
					 .pullRequestReviewCommentEvent(let reactor),
					 .publicEvent(let reactor):
					self.pushSFSafariWeb(urlString: reactor.currentState.event.openWebURL)
				}
			}).disposed(by: self.disposeBag)
		
		tableView.rx.itemSelected
			.subscribe(onNext: { [weak tableView] indexPath in
				tableView?.deselectRow(at: indexPath, animated: true)
			}).disposed(by: self.disposeBag)
	}
	
	// MARK: Notifications
	private func addNotifications() {
		NotificationCenter.default.rx.notification(.backgroundRefresh)
			.subscribe(onNext: { [weak self] _ in
				guard let self = self else { return }
				self.tableView.scrollToTop(false)
				self.reactor?.action.onNext(.firstLoad)
			}).disposed(by: self.disposeBag)
	}
	
}
