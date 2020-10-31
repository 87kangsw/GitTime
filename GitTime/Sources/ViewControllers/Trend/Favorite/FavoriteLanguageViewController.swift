//
//  FavoriteLanguageViewController.swift
//  GitTime
//
//  Created by Kanz on 2020/01/18.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import UIKit

import PanModal
import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxSwift
import Toaster

class FavoriteLanguageViewController: BaseViewController, StoryboardView, ReactorBased {

    typealias Reactor = FavoriteLanguageViewReactor
    
	enum Reusable {
		static let favoriteLanguageCell = ReusableCell<FavoriteLanguageTableViewCell>()
	}
	
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    private let close = UIBarButtonItem(title: "Close", style: .plain, target: nil, action: nil)
    
    // MARK: - Properties
    private let selectLanguageSubject = PublishSubject<Language>()
    var selectLanguage: Observable<Language> {
        return selectLanguageSubject.asObservable()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        self.title = "Favorite Languages"
        self.navigationItem.leftBarButtonItem = close
        
        tableView.rowHeight = 44.0
        
        tableView.backgroundColor = .background
        tableView.separatorColor = .underLine
		tableView.register(Reusable.favoriteLanguageCell)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        
        configureUI()
        
        // Action
        Observable.just(Void())
            .map { _ in Reactor.Action.firstLoad }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let didAppearObservable = self.rx.viewDidAppear
        let emptyObservable = reactor.state.map { $0.favoriteLanguages.isEmpty }.filter { $0 == true}
        
        Observable.combineLatest(didAppearObservable, emptyObservable)
            .filter { $0.0 == true && $0.1 == true }
            .subscribe(onNext: { _ in
                ToastCenter.default.cancelAll()
                Toast(text: "There is no registered language.", duration: Delay.short)
                    .show()
            }).disposed(by: self.disposeBag)
            
        close.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.toastMessage }
            .filterNil()
            .filterEmpty()
            .subscribe(onNext: { message in
                reactor.action.onNext(.toastMessage(nil))
                ToastCenter.default.cancelAll()
                Toast(text: message, duration: Delay.short).show()
            }).disposed(by: self.disposeBag)
        
        let dataSource = self.dataSourceFactory()
        reactor.state.map { $0.sections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)
    }
    
    private func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<FavoriteLanguageSection> {
        return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
            switch sectionItem {
            case .favorite(let cellReactor):
				let cell = tableView.dequeue(Reusable.favoriteLanguageCell, for: indexPath)
                cell.reactor = cellReactor
                
                cell.rx.favoriteTapped
                    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] language in
                        guard let self = self, let reactor = self.reactor else { return }
                        reactor.action.onNext(.removeFavorite(language))
                    }).disposed(by: cell.disposeBag)
                
                cell.rx.languageTapped
                    .subscribe(onNext: { [weak self] favoriteLanguage in
                        guard let self = self else { return }
                        let language = favoriteLanguage.toLanguage()
                        self.dismiss(animated: true, completion: { [weak self] in
                            guard let self = self else { return }
                            GitTimeAnalytics.shared.logEvent(key: "select_language",
                                                             parameters: ["language": language.name])
                            self.selectLanguageSubject.onNext(language)
                            self.selectLanguageSubject.onCompleted()
                        })
                    }).disposed(by: cell.disposeBag)
                
                return cell
            }
        })
    }
    
    // MARK: - Route
}
