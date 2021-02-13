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
//	private let modeButtonItem = UIBarButtonItem(title: "Daily", style: .plain, target: nil, action: nil)
	private let deleteButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
	
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
	
    // MARK: Properties
    
    // MARK: Initializing
    init(reactor: BuddyViewReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Buddys"
		self.navigationItem.rightBarButtonItems = [addBuddyButtonItem, modeButtonItem, deleteButtonItem]
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
    func bind(reactor: BuddyViewReactor) {
        
		self.rx.viewDidLoad
			.map { Reactor.Action.firstLoad }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		self.addBuddyButtonItem.rx.tap
			.flatMap { [weak self] _ -> Observable<String?> in
				guard let self = self else { return .empty() }
				return self.showUserNameInputAlert()
			}
			.map { Reactor.Action.checkUserExist($0) }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		self.modeButton.rx.tap
			.map { Reactor.Action.changeViewMode }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		self.deleteButtonItem.rx.tap
			.flatMap { [weak self] _ -> Observable<String?> in
				guard let self = self else { return .empty() }
				return self.showUserNameInputAlert()
			}
			.map { Reactor.Action.removeGitHubUsername($0) }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		let dataSource = self.dataSource()
		reactor.state.map { $0.sections }
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: self.disposeBag)
		
		// State
		reactor.state.map { $0.isLoading }
			.bind(to: loadingIndicator.rx.isAnimating)
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
    }
	
	private func dataSource() -> RxTableViewSectionedReloadDataSource<BuddySection> {
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
}
