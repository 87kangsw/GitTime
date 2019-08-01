//
//  ActivityViewController.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import SafariServices
import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import Toaster

class ActivityViewController: BaseViewController, StoryboardView, ReactorBased {
    
    typealias Reactor = ActivityViewReactor
    
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    lazy var contributionHeaderView: ActivityContributionView = {
        let contributionView = ActivityContributionView(frame: .zero)
        return contributionView
    }()
    var filterButton: UIBarButtonItem!
    
    // MARK: - Properties
    static var dataSource: RxTableViewSectionedReloadDataSource<ActivitySection> {
        return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
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
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ActivityItemCell.self)
                cell.reactor = reactor
                return cell
            case .empty(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EmptyTableViewCell.self)
                cell.selectionStyle = .none
                cell.reactor = reactor
                return cell
            }
        })
    }
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<ActivitySection> = type(of: self).dataSource
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func configureUI() {
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.registerNib(cellType: ActivityItemCell.self)
        tableView.registerNib(cellType: EmptyTableViewCell.self)

        let width: CGFloat = UIScreen.main.bounds.width
        
        contributionHeaderView.snp.makeConstraints { make in
            make.width.equalTo(width)
        }
        tableView.tableHeaderView = self.contributionHeaderView
    }
    
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        configureUI()
        
        // Action
        Observable.just(Void())
            .do(onNext: { _ in
                Toast(text: "Contribution crawling server starting..", duration: Delay.short).show()
            })
            .map { _ in Reactor.Action.firstLoad }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        tableView.rx.reachedBottom
            .observeOn(MainScheduler.instance)
            .map { Reactor.Action.loadMoreActivities }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.isLoading }
            .bind(to: loadingIndicator.rx.isAnimating)
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
                    self.goToWebVC(urlString: reactor.currentState.event.openWebURL)
                }
            }).disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)
    }
    
    // MARK: Go To
    fileprivate func goToWebVC(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}
