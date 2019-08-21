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
import RxCocoa
import RxDataSources
import RxKeyboard
import RxSwift

class SearchViewController: BaseViewController, StoryboardView, ReactorBased {
    
    typealias Reactor = SearchViewReactor
    
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet var tableBottomConstraint: NSLayoutConstraint!
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .default
        return searchBar
    }()
    
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
        
        tableView.backgroundColor = .clear
        tableView.registerNib(cellType: SearchUserCell.self)
        tableView.registerNib(cellType: SearchRepoCell.self)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        loadingIndicator.hidesWhenStopped = true
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
            }).disposed(by: self.disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(0.5, scheduler: MainScheduler.instance)
            .map { Reactor.Action.searchQuery($0) }
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
        
        tableView.rx.reachedBottom
            .observeOn(MainScheduler.instance)
            .map { Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        let dataSource = self.dataSource()
        reactor.state.map { $0.sections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
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
        
        tableView.rx.didScroll
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.resignFirstResponder()
            }).disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected(dataSource: dataSource)
            .subscribe(onNext: { [weak self] sectionItem in
                guard let self = self else { return }
                switch sectionItem {
                case .searchedUser(let reactor):
                    self.goToWebVC(urlString: reactor.currentState.user.url)
                case .searchedRepository(let reactor):
                    self.goToWebVC(urlString: reactor.currentState.repo.url)
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
        return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
            switch sectionItem {
            case .searchedUser(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SearchUserCell.self)
                cell.reactor = reactor
                return cell
            case .searchedRepository(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SearchRepoCell.self)
                cell.reactor = reactor
                return cell
            }
        })
    }
    
    // MARK: Go To
    fileprivate func goToWebVC(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}
