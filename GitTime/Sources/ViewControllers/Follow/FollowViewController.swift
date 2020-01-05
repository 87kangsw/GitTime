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
import RxCocoa
import RxDataSources
import RxSwift

class FollowViewController: BaseViewController, StoryboardView, ReactorBased {
    
    typealias Reactor = FollowViewReactor
    
    // MARK: - UI
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Properties
    static var dataSource: RxTableViewSectionedReloadDataSource<FollowSection> {
        return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
            switch sectionItem {
            case .followUsers(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: FollowUserCell.self)
                cell.reactor = reactor
                return cell
            }
        })
    }
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<FollowSection> = type(of: self).dataSource
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    fileprivate func configureUI() {
        
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableView.automaticDimension
        //        tableView.separatorStyle = .none
        tableView.registerNib(cellType: FollowUserCell.self)
        
        tableView.refreshControl = refreshControl
        
        tableView.backgroundColor = .background
        tableView.separatorColor = .underLine
        tableHeaderView.backgroundColor = .background
        tableView.tableFooterView = UIView()
        
        FollowTypes.allCases.enumerated().forEach { (index, type) in
            segmentControl.setTitle(type.segmentTitle, forSegmentAt: index)
        }
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .invertBackground
    }
    
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        // Action
        Observable.just(Void())
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
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
                    self.presentPanModalWeb(urlString: reactor.currentState.followUser.url)
                }
            }).disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)
        
    }
    
}
