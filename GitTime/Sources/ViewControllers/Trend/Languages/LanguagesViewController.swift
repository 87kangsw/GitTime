//
//  LanguagesViewController.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

class LanguagesViewController: BaseViewController, StoryboardView, ReactorBased {
    
    typealias Reactor = LanguagesViewReactor
    typealias ReturnType = Language
    
    // MARK: - UI
    var closeButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    
    static var dataSource: RxTableViewSectionedReloadDataSource<LanguageSection> {
        return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
            switch sectionItem {
            case .allLanguage(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: LanguageListCell.self)
                cell.reactor = reactor
                return cell
            case .languages(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: LanguageListCell.self)
                cell.reactor = reactor
                return cell
            }
        })
    }
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<LanguageSection> = type(of: self).dataSource
    
    private let selectedLanguageSubject = PublishSubject<Language>()
    var selectedLanguage: Observable<Language> {
        return selectedLanguageSubject.asObservable()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func configureUI() {
        self.title = "Languages"
        
        self.closeButton = UIBarButtonItem(title: "Close", style: .plain, target: nil, action: nil)
        self.navigationItem.setLeftBarButton(closeButton, animated: false)

        self.searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
        self.navigationItem.setRightBarButton(searchButton, animated: false)
        
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
//        let label = UILabel(frame: CGRect(x: 150, y: 50, width: 200, height: 30))
//        label.backgroundColor = .red
//        label.font = .systemFont(ofSize: 12.0)
//        let navBar = self.navigationController?.navigationBar
//        navBar?.addSubview(label)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 44
        
        tableView.registerNib(cellType: LanguageListCell.self)
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        configureUI()
        
        // Action
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
        
        segmentControl.rx.controlEvent(.valueChanged)
            .flatMap { [weak self] _ -> Observable<LanguageTypes> in
                guard let self = self else { return Observable.empty() }
                let index = self.segmentControl.selectedSegmentIndex
                return Observable.just(LanguageTypes.indexToType(index))
            }
            .map { type in Reactor.Action.selectCategory(type) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
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
            .throttle(0.3, scheduler: MainScheduler.instance)
            .filterNil()
            .map { Reactor.Action.searchQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.languageType }
            .map { LanguageTypes.typeToIndex($0)}
            .bind(to: segmentControl.rx.selectedSegmentIndex )
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.languageSections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        // View
        tableView.rx.itemSelected(dataSource: dataSource)
            .subscribe(onNext: { [weak self] sectionItem in
                guard let self = self else { return }
                self.searchController.isActive = false
                switch sectionItem {
                case .allLanguage(let reactor):
                    self.dismiss(animated: true, completion: { [weak self] in
                        guard let self = self else { return }
                        let language = reactor.currentState.language
                        self.selectedLanguageSubject.onNext(language)
                        self.selectedLanguageSubject.onCompleted()
                    })
                case .languages(let reactor):
                    self.dismiss(animated: true, completion: { [weak self] in
                        guard let self = self else { return }
                        let language = reactor.currentState.language
                        self.selectedLanguageSubject.onNext(language)
                        self.selectedLanguageSubject.onCompleted()
                    })
                }
            }).disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)
    }
}
