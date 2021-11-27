//
//  TrendViewController.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import SafariServices
import UIKit

import PanModal
import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxSwift

class TrendViewController: BaseViewController, ReactorKit.View {
    
    typealias Reactor = TrendViewReactor
    
	enum Reusable {
		static let trendingRepoCell = ReusableCell<TrendingRepositoryCell>()
		static let trendingDeveloperCell = ReusableCell<TrendingDeveloperCell>()
//		static let emptyCell = ReusableCell<EmptyTableViewCell>()
	}
	
	// MARK: Views
	private let tableView = UITableView(frame: .zero, style: .plain).then {
		$0.estimatedRowHeight = 64.0
		$0.rowHeight = UITableView.automaticDimension
		$0.register(Reusable.trendingRepoCell)
		$0.register(Reusable.trendingDeveloperCell)
//		$0.register(Reusable.emptyCell)
		$0.backgroundColor = .background
		$0.separatorColor = .underLine
	}
	
	private let tableHeaderView = TrendingHeaderView().then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.frame = CGRect(x: 0, y: 0,
						  width: UIScreen.main.bounds.width,
						  height: 100)
	}
	
	private let loadingIndicator = UIActivityIndicatorView().then {
		$0.hidesWhenStopped = true
		$0.color = .invertBackground
	}
	
	private let refreshControl = UIRefreshControl()
    private var favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "favorite_fill"), for: .normal)
        return button
    }()
    lazy var favoriteBarButton = UIBarButtonItem(customView: favoriteButton)
	
	let filterButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"),
									   style: .plain,
									   target: nil,
									   action: nil)
    
    // MARK: - Properties
    static var dataSource: RxTableViewSectionedReloadDataSource<TrendSection> {
        return .init(configureCell: { (_, tableView, indexPath, sectionItem) -> UITableViewCell in
            switch sectionItem {
            case .trendingRepos(let reactor):
				let cell = tableView.dequeue(Reusable.trendingRepoCell, for: indexPath)
                cell.reactor = reactor
                return cell
            case .trendingDevelopers(let reactor):
				let cell = tableView.dequeue(Reusable.trendingDeveloperCell, for: indexPath)
                let rank = indexPath.row
                cell.reactor = reactor
                cell.reactor?.action.onNext(.initRank(rank))
                return cell
//            case .empty(let reactor):
//				let cell = tableView.dequeue(Reusable.emptyCell, for: indexPath)
//                cell.reactor = reactor
//                return cell
            }
        })
    }
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<TrendSection> = type(of: self).dataSource
    
    private var periodActions: [RxAlertAction<String>] {
        var actions = [RxAlertAction<String>]()
        PeriodTypes.allCases.forEach { type in
            let action = RxAlertAction<String>(title: type.buttonTitle(), style: .default, result: type.rawValue)
            actions.append(action)
        }
        let cancelAction = RxAlertAction<String>(title: "Cancel", style: .cancel, result: "")
        actions.append(cancelAction)
        return actions
    }
    
	private let presentLanguageScreen: () -> LanguageListViewController
	private let presentFavoriteScreen: () -> FavoriteLanguageViewController
	
	// MARK: - Initializing
	init(
		reactor: Reactor,
		presentLanguageScreen: @escaping () -> LanguageListViewController,
		presentFavoriteScreen: @escaping () -> FavoriteLanguageViewController
	) {
		defer { self.reactor = reactor }		
		self.presentLanguageScreen = presentLanguageScreen
		self.presentFavoriteScreen = presentFavoriteScreen
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.rightBarButtonItem = favoriteBarButton
		addNotifications()
    }
    
	override func addViews() {
		super.addViews()
		
		self.view.addSubview(tableView)
		tableView.refreshControl = refreshControl
		tableView.tableFooterView = UIView()
		
		tableView.tableHeaderView = tableHeaderView
		
		self.view.addSubview(loadingIndicator)
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		tableHeaderView.snp.makeConstraints { make in
			make.height.equalTo(100.0)
			make.width.equalTo(tableView.snp.width)
		}
		
		loadingIndicator.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
	
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
		bindTrendingHeaderSubReactor(reactor: reactor)
		
        // Action
        Observable.just(Void())
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
		
		favoriteButton.rx.tap
			.flatMap { [weak self] _ -> Observable<GithubLanguage> in
				guard let self = self else { return .empty() }
				return self.presentFavorite()
			}
			.map { Reactor.Action.selectLanguage($0) }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
        // State
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating )
            .disposed(by: self.disposeBag)

        reactor.state.map { $0.trendSections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)

        // View
        tableView.rx.itemSelected(dataSource: dataSource)
            .subscribe(onNext: { [weak self] sectionItem in
                guard let self = self else { return }
                switch sectionItem {
                case .trendingRepos(let reactor):
                    self.pushSFSafariWeb(urlString: reactor.currentState.url)
                case .trendingDevelopers(let reactor):
                    self.pushSFSafariWeb(urlString: reactor.currentState.url)
//                case .empty:
//                    break
                }
            }).disposed(by: self.disposeBag)

		tableView.rx.setDelegate(self)
			.disposed(by: self.disposeBag)
		
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)
    }
	
	func bindTrendingHeaderSubReactor(reactor: Reactor) {
		tableHeaderView.reactor = reactor.headerViewReactor
		
		tableHeaderView.rx.segmentValueChanged
			.map { Reactor.Action.switchSegmentControl }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		tableHeaderView.rx.periodButtonTapped
			.subscribe(onNext: { [weak self] _ in
				guard let self = self else { return }
				let sheet = UIAlertController.rx_presentAlert(viewController: self,
															  preferredStyle: .actionSheet,
															  animated: true,
															  button: self.tableHeaderView.periodButton,
															  actions: self.periodActions)
				sheet.subscribe(onNext: { selectedPeriod in
					guard let period = PeriodTypes(rawValue: selectedPeriod) else { return }
					reactor.action.onNext(.selectPeriod(period))
				}).disposed(by: self.disposeBag)
			}).disposed(by: self.disposeBag)
		
		tableHeaderView.rx.languageButtonTapped
			.flatMap { [weak self] _ -> Observable<GithubLanguage> in
				guard let self = self else { return .empty() }
				let controller = self.presentLanguageScreen()
				self.present(controller.navigationWrap(), animated: true, completion: nil)
				return controller.selectedLanguage
			}.subscribe(onNext: { language in
				// let languageName = language.type != .all ? language.name : nil
				reactor.action.onNext(.selectLanguage(language))
			}).disposed(by: self.disposeBag)
	}
    
	// MARK: Notifications
	private func addNotifications() {
		NotificationCenter.default.rx.notification(.backgroundRefresh)
			.subscribe(onNext: { [weak self] _ in
				guard let self = self else { return }
				self.tableView.scrollToTop(false)
				self.reactor?.action.onNext(.refresh)
			}).disposed(by: self.disposeBag)
	}
	
    // MARK: - Route
    private func presentFavorite() -> Observable<GithubLanguage> {
		let controller = self.presentFavoriteScreen()
        let navVC = PanModalNaivgationController()
        navVC.viewControllers = [controller]
        presentPanModal(navVC)
        return controller.selectLanguage
    }
}

// MARK: UITableViewDelegate (UIContextMenuConfiguration)
extension TrendViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let reactor = self.reactor else { return nil }
		switch reactor.currentState.trendingType {
		case .repositories:
			return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
				let item = reactor.currentState.repositories[indexPath.row]
				switch item {
				case .trendingRepos(let cellReactor):
					let contributorActions = cellReactor.currentState.contributors.map { contributor -> UIAction in
						UIAction(title: contributor.name,
								 image: UIImage(systemName: "person.circle")) { _ in
							self.pushSFSafariWeb(urlString: contributor.githubURL)
						}
					}
					return UIMenu(title: "Contributors", children: contributorActions)
					
				default:
					return nil
				}
			}
			
		case .developers:
			return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
				let item = reactor.currentState.developers[indexPath.row]
				switch item {
				case .trendingDevelopers(let cellReactor):
					guard let userName = cellReactor.currentState.userName else { return nil }
					let actionTitle = userName.isNotEmpty ? userName : cellReactor.currentState.name
					
					var actions: [UIMenuElement] = []
					let developerAction = UIAction(title: actionTitle,
												   image: UIImage(systemName: "person.circle")) { _ in
						self.pushSFSafariWeb(urlString: cellReactor.currentState.url)
					}
					actions.append(developerAction)
					
					let popularRepoAction = UIAction(title: cellReactor.currentState.repoName,
													 image: UIImage(named: "create_repo")) { _ in
						self.pushSFSafariWeb(urlString: cellReactor.currentState.popularRepoURL)
					}
					actions.append(popularRepoAction)
					
					return UIMenu(title: "Developer", children: actions)
					
				default:
					return nil
				}
			}
		}
	}
}
