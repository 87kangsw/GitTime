//
//  SettingViewController.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import MessageUI
import SafariServices
import UIKit

import AcknowList
import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

class SettingViewController: BaseViewController, StoryboardView, ReactorBased {
    
    typealias Reactor = SettingViewReactor
    
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    static var dataSource: RxTableViewSectionedReloadDataSource<SettingSection> {
        return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
            switch sectionItem {
            case .myProfile(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SettingUserProfileCell.self)
                cell.reactor = reactor
                return cell
            case .logout(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SettingLogoutCell.self)
                cell.reactor = reactor
                return cell
            case .acknowledgements(let reactor),
                 .contact(let reactor),
                 .githubRepo(let reactor),
                 .rateApp(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SettingItemCell.self)
                cell.reactor = reactor
                return cell
            case .version(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SettingItemCell.self)
                cell.reactor = reactor
//                reactor.action.onNext(.updateSubTitle(version))
                return cell
            }
        })
    }
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<SettingSection> = type(of: self).dataSource
    
    private var logoutActions: [RxAlertAction<Bool>] {
        var actions = [RxAlertAction<Bool>]()
        let logoutAction = RxAlertAction<Bool>(title: "Logout", style: .destructive, result: true)
        let cancelAction = RxAlertAction<Bool>(title: "Cancel", style: .cancel, result: false)
        actions.append(logoutAction)
        actions.append(cancelAction)
        return actions
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    fileprivate func configureUI() {
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 64.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        tableView.registerNib(cellType: SettingUserProfileCell.self)
        tableView.registerNib(cellType: SettingItemCell.self)
        tableView.registerNib(cellType: SettingLogoutCell.self)
    }
    
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        // Action
        Observable.just(Void())
            .map { Reactor.Action.versionCheck }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.settingSections }
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isLoggedOut }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.goToLogin()
            }).disposed(by: self.disposeBag)
        
        // View
        tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected(dataSource: dataSource)
            .subscribe(onNext: { [weak self] sectionItem in
                guard let self = self else { return }
                switch sectionItem {
                case .myProfile:
                    self.goToMyProfile(reactor.currentState.pageURL)
                case .githubRepo:
                    self.goToRepository()
                case .acknowledgements:
                    self.goToAcknowledgements()
                case .contact:
                    self.goToContactEmail()
                case .rateApp:
                    self.goToRateApp()
                case .version:
                    self.goToAppStore()
                case .logout:
                    let alert = UIAlertController.rx_presentAlert(viewController: self,
                                                                  title: "Are you sure you want to logout?",
                                                                  message: nil,
                                                                  preferredStyle: .alert,
                                                                  animated: true,
                                                                  actions: self.logoutActions)
                    alert.subscribe(onNext: { loggedOut in
                        guard loggedOut else { return }
                        reactor.action.onNext(.logout)
                    }).disposed(by: self.disposeBag)
                }
            }).disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)
        
    }
    
    // MARK: - Go To
    fileprivate func goToMyProfile(_ pageURL: String) {
        guard let url = URL(string: pageURL) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    fileprivate func goToRepository() {
        guard let url = URL(string: AppConstants.gitTimeRepositoryURL) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    fileprivate func goToAcknowledgements() {
        let acknowVC = AcknowListViewController()
        self.navigationController?.pushViewController(acknowVC, animated: true)
    }
    
    fileprivate func goToContactEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Email Not available..",
                                          message: "Email is not available for this device.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([AppConstants.contactMailAddress])
        composeVC.setSubject(AppConstants.contactMailTitle)
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    fileprivate func goToRateApp() {
        let urlString = "https://itunes.apple.com/app/id\(AppConstants.appID)?action=write-review"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    fileprivate func goToAppStore() {
        let urlString = "https://itunes.apple.com/app/id\(AppConstants.appID)"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    fileprivate func goToLogin() {
        AppDependency.shared.configureCoordinator(launchOptions: nil,
                                                  window: UIApplication.shared.keyWindow!)
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20.0))
        view.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.00)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0.0 }
        return 32.0
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
