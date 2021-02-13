//
//  LanguagesViewController.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import Toaster

class LanguagesViewController: BaseViewController, ReactorKit.View {
    
    typealias Reactor = LanguagesViewReactor
    typealias ReturnType = Language
    
	enum Reusable {
		static let languageCell = ReusableCell<LanguageCell>()
		static let favoriteLanguageCell = ReusableCell<FavoriteLanguageCell>()
	}
	
    // MARK: - UI
    var closeButton: UIBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: nil, action: nil)
    var searchButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
    
    private let tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.rowHeight = 44.0
		$0.backgroundColor = .background
		$0.separatorColor = .underLine
		
		$0.register(Reusable.languageCell)
//		$0.register(Reusable.favoriteLanguageCell)
    }

    private let headerView = LanguageCategoryView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.backgroundColor = .background
		$0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 65.0)
    }
	
    // MARK: - Properties
	let searchController = UISearchController(searchResultsController: nil).then {
		$0.obscuresBackgroundDuringPresentation = false
	}

    private var dataSource: RxTableViewSectionedReloadDataSource<LanguageSection>!
    
    private let selectedLanguageSubject = PublishSubject<Language>()
    var selectedLanguage: Observable<Language> {
        return selectedLanguageSubject.asObservable()
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
		self.title = "Languages"
		
		self.navigationItem.setLeftBarButton(closeButton, animated: false)
		self.navigationItem.setRightBarButton(searchButton, animated: false)
		navigationItem.searchController = searchController
    }
    
	override func addViews() {
		super.addViews()
		
		self.view.addSubview(tableView)
		tableView.tableHeaderView = headerView
		tableView.tableFooterView = UIView()
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
		bindCategoryViewReactor(reactor: reactor)
		
        dataSource = self.dataSourceFactory()
        
        // Action
        Observable.just(Void())
            .map { Reactor.Action.firstLoad }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        Observable.just(Void())
            .map { _ in Reactor.Action.selectCategory(reactor.initialState.languageType) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        searchButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchController.isActive = true
                reactor.action.onNext(.searchActive(true))
            }).disposed(by: self.disposeBag)
        
        searchController.rx.willPresent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.tableHeaderView = nil
            }).disposed(by: self.disposeBag)
        
        searchController.rx.willDismiss
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.tableHeaderView = self.headerView
                reactor.action.onNext(.searchActive(false))
                reactor.action.onNext(.selectCategory(reactor.currentState.languageType))
            }).disposed(by: self.disposeBag)
        
        searchController.searchBar.rx.text
            .throttle(.microseconds(300), scheduler: MainScheduler.instance)
            .filterNil()
            .map { Reactor.Action.searchQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.languageSections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.toastMessage }
            .filterNil()
            .filterEmpty()
            .subscribe(onNext: { message in
                reactor.action.onNext(.toastMessage(nil))
                ToastCenter.default.cancelAll()
                Toast(text: message, duration: Delay.short).show()
            }).disposed(by: self.disposeBag)
        
        // View
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)
    }
	
	private func bindCategoryViewReactor(reactor: Reactor) {
		self.headerView.reactor = reactor.categoryViewReactor
		
		self.headerView.languageCategoryObservable
			.map { type in Reactor.Action.selectCategory(type) }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
	}
    
    private func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<LanguageSection> {
        return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
            switch sectionItem {
            case .allLanguage(let reactor):
				let cell = tableView.dequeue(Reusable.languageCell, for: indexPath)
                cell.reactor = reactor
                
                cell.rx.languageTapped
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        self.searchController.isActive = false
                        self.dismiss(animated: true, completion: { [weak self] in
                            guard let self = self else { return }
                            let language = reactor.currentState.language
                            GitTimeAnalytics.shared.logEvent(key: "select_all_language",
                                                             parameters: nil)
                            self.selectedLanguageSubject.onNext(language)
                            self.selectedLanguageSubject.onCompleted()
                        })
                    }).disposed(by: cell.disposeBag)
                
                return cell
            case .languages(let reactor):
				let cell = tableView.dequeue(Reusable.languageCell, for: indexPath)
                cell.reactor = reactor
                
                cell.rx.favoriteTapped
                    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] language in
                        guard let self = self, let reactor = self.reactor else { return }
                        reactor.action.onNext(.selectFavorite(language))
                    }).disposed(by: cell.disposeBag)
                
                cell.rx.languageTapped
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        self.dismiss(animated: true, completion: { [weak self] in
                            guard let self = self else { return }
                            let language = reactor.currentState.language
                            GitTimeAnalytics.shared.logEvent(key: "select_language",
                                                             parameters: ["language": language.name])
                            self.selectedLanguageSubject.onNext(language)
                            self.selectedLanguageSubject.onCompleted()
                        })
                    }).disposed(by: cell.disposeBag)
                
                return cell
                
            case .emptyFavorites(let cellReactor):
				let cell = tableView.dequeue(Reusable.favoriteLanguageCell, for: indexPath)
                cell.reactor = cellReactor
                return cell
            }
        })
    }
}
