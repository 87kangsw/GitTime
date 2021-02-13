//
//  SearchViewController.swift
//  GitTime
//
//  Created by Kanz on 09/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import SafariServices
import UIKit

import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxKeyboard
import RxSwift

class SearchViewController: BaseViewController, StoryboardView, ReactorBased {
    
    typealias Reactor = SearchViewReactor
    
	enum Reusable {
		static let searchUserCell = ReusableCell<SearchUserCell>()
		static let searchReporCell = ReusableCell<SearchRepoCell>()
		static let searchHistoryCell = ReusableCell<SearchHistoryCell>()
		static let emptyCell = ReusableCell<EmptyTableViewCell>()
	}
	
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet var segmentBottomToLanguageConstraint: NSLayoutConstraint!
    @IBOutlet var segmentBottomToSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet var tableBottomConstraint: NSLayoutConstraint!
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .default
        return searchBar
    }()
    @IBOutlet weak var languageButton: UIButton!
    
    // MARK: - Properties
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    fileprivate func configureUI() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.titleView = searchBar
        
        SearchTypes.allCases.enumerated().forEach { (index, type) in
            segmentControl.setTitle(type.segmentTitle, forSegmentAt: index)
        }
        
		tableView.register(Reusable.searchUserCell)
		tableView.register(Reusable.searchReporCell)
		tableView.register(Reusable.searchHistoryCell)
		tableView.register(Reusable.emptyCell)
		
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .background
        tableView.separatorColor = .underLine
        tableHeaderView.backgroundColor = .background
        tableView.tableFooterView = UIView()
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .invertBackground
    }
    
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        // Action
        searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.resignFirstResponder()
            }).disposed(by: self.disposeBag)
        
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.resignFirstResponder()
                reactor.action.onNext(.searchQuery(self.searchBar.text))
            }).disposed(by: self.disposeBag)

        searchBar.rx.textDidBeginEditing
            .map { Reactor.Action.showRecentSearchWords(true) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        segmentControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .map { SearchTypes(rawValue: $0) }
            .filterNil()
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                self.searchBar.placeholder = type.placeHolderText
                self.searchBar.text = nil
                reactor.action.onNext(.selectType(type))
            }).disposed(by: self.disposeBag)
        
        segmentControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .map { SearchTypes(rawValue: $0) }
            .filterNil()
            .subscribe(onNext: { [weak self] type in
                guard let self = self, let headerView = self.tableView.tableHeaderView else { return }
                self.updateHeaderViewFrame(headerView, type: type)
                self.languageButton.isHidden = type == .users
            }).disposed(by: self.disposeBag)
        
        tableView.rx.reachedBottom
            .observeOn(MainScheduler.instance)
            .map { Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        languageButton.rx.tap
            .flatMap { [weak self] _ -> Observable<Language> in
                guard let self = self else { return .empty() }
                let languageReactor = LanguagesViewReactor(languagesService: LanguagesService(),
                                                           userDefaultsService: UserDefaultsService(),
                                                           realmService: RealmService())
                let languageVC = LanguagesViewController(reactor: languageReactor)
                self.present(languageVC.navigationWrap(), animated: true, completion: nil)
                return languageVC.selectedLanguage
        }.subscribe(onNext: { language in
            // let languageName = language.type != .all ? language.name : nil
            reactor.action.onNext(.selectLanguage(language))
        }).disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        let dataSource = self.dataSource()
        reactor.state.map { $0.sections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.language }
            .map { language -> String in
                return language?.name ?? LanguageTypes.all.buttonTitle()
        }
        .bind(to: languageButton.rx.title())
        .disposed(by: self.disposeBag)
        
        // View
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.showsCancelButton = true
            }).disposed(by: self.disposeBag)
        
        searchBar.rx.textDidEndEditing
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.showsCancelButton = false
            }).disposed(by: self.disposeBag)
                
        tableView.rx.itemSelected(dataSource: dataSource)
            .subscribe(onNext: { [weak self] sectionItem in
                guard let self = self else { return }
                switch sectionItem {
                case .searchedUser(let reactor):
                    self.pushSFSafariWeb(urlString: reactor.currentState.user.url)
                case .searchedRepository(let reactor):
                    self.pushSFSafariWeb(urlString: reactor.currentState.repo.url)
                case .recentWord(let cellReactor):
                    let searchWords = cellReactor.currentState.history.text
                    self.searchBar.resignFirstResponder()
                    reactor.action.onNext(.searchQuery(searchWords))
                }
            }).disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)
        
        // Keyboard
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self else { return }
                var actualKeyboardHeight = keyboardVisibleHeight
                actualKeyboardHeight -= self.view.safeAreaInsets.bottom
                self.tableBottomConstraint.constant = actualKeyboardHeight
                self.view.setNeedsLayout()
            }).disposed(by: self.disposeBag)
    }
    
    fileprivate func dataSource() -> RxTableViewSectionedReloadDataSource<SearchResultsSection> {
        return .init(configureCell: { [weak self] (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
            switch sectionItem {
            case .searchedUser(let reactor):
				let cell = tableView.dequeue(Reusable.searchUserCell, for: indexPath)
                cell.reactor = reactor
                return cell
            case .searchedRepository(let reactor):
				let cell = tableView.dequeue(Reusable.searchReporCell, for: indexPath)
                cell.reactor = reactor
                return cell
            case .recentWord(let cellReactor):
				let cell = tableView.dequeue(Reusable.searchHistoryCell, for: indexPath)
                cell.reactor = cellReactor
                
                cell.rx.deleteButtonTap
                    .subscribe(onNext: { [weak self] (indexPath, text) in
                        guard let self = self, let reactor = self.reactor else { return }
                        guard let indexPath = indexPath, let text = text else { return }
                        reactor.action.onNext(.removeRecentSearchWord(indexPath, text))
                    }).disposed(by: cell.disposeBag)
                
                return cell
            }
        }, titleForHeaderInSection: { (datasource, index) -> String? in
            let sectionItem = datasource.sectionModels[index]
            switch sectionItem {
            case .recentSearchWords:
                return "Recent search words"
            default:
                return nil
            }
        })
    }
    
    private func updateHeaderViewFrame(_ headerView: UIView, type: SearchTypes) {
        var frame = headerView.frame
        switch type {
        case .users:
            frame.size.height = 63.0
            self.segmentBottomToLanguageConstraint.isActive = false
            self.segmentBottomToSuperViewConstraint.isActive = true
        case .repositories:
            frame.size.height = 117.0
            self.segmentBottomToLanguageConstraint.isActive = true
            self.segmentBottomToSuperViewConstraint.isActive = false
        }
        headerView.frame = frame
        self.tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
    }
}
