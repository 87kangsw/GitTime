//
//  BuddyViewController.swift
//  GitTime
//
//  Created Kanz on 2020/10/31.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import ReusableKit
import Toaster

enum ButtonAddType: CaseIterable {
	case follow
	case manualInput
	case cancel
	
	var title: String {
		switch self {
		case .follow:
			return "Follow"
		case .manualInput:
			return "Manual Input"
		case .cancel:
			return "Cancel"
		}
	}
	
	var style: UIAlertAction.Style {
		switch self {
		case .cancel: return .cancel
		default: return .default
		}
	}
}

final class BuddyViewController: BaseViewController, ReactorKit.View {
    
    typealias Reactor = BuddyViewReactor
    
    private struct Reusable {
		static let dailyCell = ReusableCell<BuddyDailyCell>()
		static let weeklyCell = ReusableCell<BuddyYearlyCell>()
    }
    
	// MARK: Views
	private let addBuddyButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
	private let modeButton = UIButton().then {
		$0.setImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
	}
	lazy var modeButtonItem = UIBarButtonItem(customView: modeButton)
	private let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
	
	private let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
		$0.estimatedRowHeight = 100.0
		$0.rowHeight = UITableView.automaticDimension
		$0.register(Reusable.dailyCell)
		$0.register(Reusable.weeklyCell)
		$0.backgroundColor = .systemGroupedBackground
	}
	private let loadingIndicator = UIActivityIndicatorView().then {
		$0.hidesWhenStopped = true
		$0.style = .large
		$0.color = .invertBackground
	}
	private let refreshControl = UIRefreshControl()
	
    // MARK: Properties
	private var dataSource: RxTableViewSectionedReloadDataSource<BuddySection>!
	
	private var addActions: [RxAlertAction<ButtonAddType>] {
		var actions: [RxAlertAction<ButtonAddType>] = []
		
		ButtonAddType.allCases.forEach { type in
			let action = RxAlertAction<ButtonAddType>(title: type.title, style: type.style, result: type)
			actions.append(action)
		}
		
		return actions
	}
    
	private let presentFollowScreen: () -> FollowViewController
	
    // MARK: Initializing
	init(reactor: BuddyViewReactor,
		 presentFollowScreen: @escaping () -> FollowViewController) {
		defer { self.reactor = reactor }
		self.presentFollowScreen = presentFollowScreen
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Buddys"
		self.navigationItem.leftBarButtonItem = editButton
		self.navigationItem.rightBarButtonItems = [addBuddyButtonItem, modeButtonItem]
		addNotifications()
    }
    
    override func addViews() {
        super.addViews()
		self.view.addSubview(tableView)
		self.view.addSubview(loadingIndicator)
		tableView.refreshControl = refreshControl
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
    func bind(reactor: BuddyViewReactor) {
        
		self.rx.viewDidLoad
			.map { Reactor.Action.firstLoad }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)

		self.addBuddyButtonItem.rx.tap
			.subscribe(onNext: { [weak self] _ in
				guard let self = self else { return }
				let sheet = UIAlertController.rx_presentAlert(viewController: self,
															  preferredStyle: .actionSheet,
															  animated: true,
															  button: self.addBuddyButtonItem,
															  actions: self.addActions)
				sheet.subscribe(onNext: { [weak self] type in
					guard let self = self else { return }
					switch type {
					case .cancel:
						break
					case .manualInput:
						self.showUserNameInputAlert()
							.map { Reactor.Action.checkGitHubUser($0) }
							.bind(to: reactor.action)
							.disposed(by: self.disposeBag)
					case .follow:
						self.presentFollowViewController()
							.map { Reactor.Action.checkUserExist($0.name) }
							.bind(to: reactor.action)
							.disposed(by: self.disposeBag)
					}
				}).disposed(by: self.disposeBag)
				
			}).disposed(by: self.disposeBag)
		
		self.modeButton.rx.tap
			.map { Reactor.Action.changeViewMode }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		self.editButton.rx.tap
			.subscribe(onNext: { [weak self] _ in
				guard let self = self else { return }
				let editing = self.tableView.isEditing
				self.tableView.setEditing(!editing, animated: true)
			}).disposed(by: self.disposeBag)
		
		refreshControl.rx.controlEvent(.valueChanged)
			.map { Reactor.Action.refresh }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		dataSource = self.dataSourceFactory()
		reactor.state.map { $0.sections }
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: self.disposeBag)
		
		// State
		reactor.state.map { $0.isLoading }
			.bind(to: loadingIndicator.rx.isAnimating)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.isRefreshing }
			.distinctUntilChanged()
			.bind(to: refreshControl.rx.isRefreshing)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.buddys }
			.observeOn(MainScheduler.asyncInstance)
			.distinctUntilChanged()
			.filterEmpty()
			.take(1)
			.map { _ in Reactor.Action.checkUpdate }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.viewMode }
			.distinctUntilChanged()
			.map { $0.systemIconName }
			.map { UIImage(systemName: $0) }
			.bind(to: self.modeButton.rx.image(for: .normal))
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.alreadyExistUser }
			.filterNil()
			.subscribe(onNext: { [weak self] (exist, userName) in
				guard let self = self else { return }
				reactor.action.onNext(.clearCheckExist)
				if exist {
					self.showAlreadyExistUserAlert()
				} else {
					reactor.action.onNext(.addGitHubUsername(userName))
				}
				log.debug(exist)
			}).disposed(by: self.disposeBag)
		
		tableView.rx.setDelegate(self)
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.toastMessage }
			.filterNil()
			.filterEmpty()
			.subscribe(onNext: { message in
				reactor.action.onNext(.toastMessage(nil))
				ToastCenter.default.cancelAll()
				Toast(text: message, duration: Delay.short).show()
			}).disposed(by: self.disposeBag)
		
		tableView.rx.itemSelected(dataSource: dataSource)
			.subscribe(onNext: { [weak self] sectionItem in
				guard let self = self else { return }
				switch sectionItem {
				case .daily(let cellReactor):
					let user = cellReactor.currentState.contributionInfo.additionalName
					guard user.isNotEmpty else { return }
					let urlString = "https://github.com/\(user)"
					self.pushSFSafariWeb(urlString: urlString)
				case .weekly(let cellReactor):
					let user = cellReactor.currentState.contributionInfo.additionalName
					guard user.isNotEmpty else { return }
					let urlString = "https://github.com/\(user)"
					self.pushSFSafariWeb(urlString: urlString)
				}
			}).disposed(by: self.disposeBag)
    }
	
	private func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<BuddySection> {
		return .init(configureCell: { (dataSource, tableView, indexPath, sectionItem) -> UITableViewCell in
			switch sectionItem {
			case .daily(let cellReactor):
				let cell = tableView.dequeue(Reusable.dailyCell, for: indexPath)
				cell.reactor = cellReactor
				return cell
			case .weekly(let cellReactor):
				let cell = tableView.dequeue(Reusable.weeklyCell, for: indexPath)
				cell.reactor = cellReactor
				return cell
			}
		}, canEditRowAtIndexPath: { (dataSource, indexPath) -> Bool in
			return true
		})
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
	
	// MARK: Route
	private func showUserNameInputAlert() -> Observable<String?> {
		return Observable.create { [weak self] observer -> Disposable in
			guard let self = self else {
				observer.onCompleted()
				return Disposables.create { }
			}
			
			let alert = UIAlertController(title: "GitHub Username", message: "Input username for contributions", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
				observer.onCompleted()
			}))
				
			alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
				let inputText = alert.textFields?.first?.text
				observer.onNext(inputText)
				observer.onCompleted()
			}))
			
			alert.addTextField { textField in
				textField.placeholder = "GitHub username"
			}
			
			self.present(alert, animated: true, completion: nil)
			
			return Disposables.create {
				
			}
		}
	}
	
	private func showAlreadyExistUserAlert() {
		let alert = UIAlertController(title: "Already Exist User", message: "Pl", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	private func presentFollowViewController() -> Observable<User> {
		let controller = self.presentFollowScreen()
		self.present(controller.navigationWrap(), animated: true, completion: nil)
		return controller.selectedUser
	}
}

extension BuddyViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let section = dataSource[indexPath.section]
		switch section {
		case .buddys(let items):
			guard let reactor = self.reactor else { return nil }
			let sectionItem = items[indexPath.row]
			switch sectionItem {
			case .daily(let cellReactor):
				let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
					reactor.action.onNext(.removeGitHubUsername(cellReactor.currentState.contributionInfo.additionalName))
					completion(true)
				}
				return UISwipeActionsConfiguration(actions: [deleteAction])
			case .weekly(let cellReactor):
				let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
					reactor.action.onNext(.removeGitHubUsername(cellReactor.currentState.contributionInfo.additionalName))
					completion(true)
				}
				return UISwipeActionsConfiguration(actions: [deleteAction])
			}
		}
	}
}
