//
//  SettingViewController.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import MessageUI
import SafariServices
import StoreKit
import UIKit

import AcknowList
import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

class SettingViewController: BaseViewController, ReactorKit.View {
    
    typealias Reactor = SettingViewReactor
    
	enum Reusable {
		static let menuCell = ReusableCell<SettingCell>()
	}
	
    // MARK: - UI
	private let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
		$0.rowHeight = 50.0
		$0.register(Reusable.menuCell)
		$0.backgroundColor = .systemGroupedBackground
	}
    
    // MARK: - Properties
    private var logoutActions: [RxAlertAction<Bool>] {
        var actions = [RxAlertAction<Bool>]()
        let logoutAction = RxAlertAction<Bool>(title: "Logout", style: .destructive, result: true)
        let cancelAction = RxAlertAction<Bool>(title: "Cancel", style: .cancel, result: false)
        actions.append(logoutAction)
        actions.append(cancelAction)
        return actions
    }
	
	private let presentLoginScreen: () -> Void
	private let pushAppIconScreen: () -> AppIconsViewController
	private let pushContributorsScreen: () -> ContributorsViewController
	
	// MARK: - Initializing
	init(
		reactor: Reactor,
		presentLoginScreen: @escaping () -> Void,
		pushAppIconScreen: @escaping () -> AppIconsViewController,
		pushContributorsScreen: @escaping () -> ContributorsViewController
	) {
		defer { self.reactor = reactor }
		self.presentLoginScreen = presentLoginScreen
		self.pushAppIconScreen = pushAppIconScreen
		self.pushContributorsScreen = pushContributorsScreen
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tabBarController?.tabBar.isHidden = false
	}
	
	override func addViews() {
		super.addViews()
		
		self.view.addSubview(tableView)
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		self.tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
    
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        // Action
		self.rx.viewDidAppear
			.take(1)
			.map { _ in Reactor.Action.reviewRequest }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
        
        // State
		let dataSource = self.dataSource()
		
        reactor.state.map { $0.settingSections }
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isLoggedOut }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
				self.presentLoginScreen()
            }).disposed(by: self.disposeBag)
        
		reactor.state.map { $0.isShowReviewRereuqestAlert }
			.distinctUntilChanged()
			.filter { $0 == true }
			.take(1)
			.subscribe(onNext: { _ in
				SKStoreReviewController.requestReview()
			}).disposed(by: self.disposeBag)
		
        // View
        tableView.rx.itemSelected(dataSource: dataSource)
            .subscribe(onNext: { [weak self] sectionItem in
                guard let self = self else { return }
                switch sectionItem {
				case .appIcon:
					self.goToAppIcon()
				case .repo:
					self.goToGitTimeRepository()
				case .opensource:
					self.goToAcknowledgements()
				case .recommend:
					self.goToRecommendApp()
				case .appReview:
					self.goToRateApp()
				case .privacy:
					self.goToPrivacy()
				case .author:
					self.goToAuthorTwitter()
				case .contributors:
					self.goToContributors()
				case .shareFeedback:
					self.goToSendFeedback()
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
	
	private func dataSource() -> RxTableViewSectionedReloadDataSource<SettingSection> {
		return .init(configureCell: { (_, tableView, indexPath, sectionItem) -> UITableViewCell in
			switch sectionItem {
			case .appIcon(let reactor),
				 .appReview(let reactor),
				 .author(let reactor),
				 .contributors(let reactor),
				 .logout(let reactor),
				 .opensource(let reactor),
				 .privacy(let reactor),
				 .recommend(let reactor),
				 .repo(let reactor),
				 .shareFeedback(let reactor):
				let cell = tableView.dequeue(Reusable.menuCell, for: indexPath)
				cell.reactor = reactor
				return cell
			}
		})
	}
    
    // MARK: - Go To
	private func goToAppIcon() {
		let controller = self.pushAppIconScreen()
		self.navigationController?.pushViewController(controller, animated: true)
		self.tabBarController?.tabBar.isHidden = true
	}
	
	private func goToGitTimeRepository() {
		self.pushSFSafariWeb(urlString: Constants.URLs.gitTimeRepositoryURL)
	}
	
	private func goToAcknowledgements() {
		let acknowVC = AcknowListViewController()
		self.navigationController?.pushViewController(acknowVC, animated: true)
		self.tabBarController?.tabBar.isHidden = true
	}
	
	private func goToRecommendApp() {
		guard let url = URL(string: Constants.URLs.appStoreURL) else { return }
		let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
		if UIDevice.isPad == true {
			guard let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) else { return }
			activityController.popoverPresentationController?.sourceView = self.tableView
			activityController.popoverPresentationController?.sourceRect = cell.frame
		}
		self.present(activityController, animated: true, completion: nil)
	}
	
	private func goToRateApp() {
		let urlString = "https://itunes.apple.com/app/id\(AppConstants.appID)?action=write-review"
		guard let url = URL(string: urlString) else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
	
	private func goToPrivacy() {
		self.pushSFSafariWeb(urlString: Constants.URLs.privacyURL)
	}
	
	private func goToAuthorTwitter() {
		let urlString = Constants.Schemes.twitter
		guard let url = URL(string: urlString) else { return }
		if UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		} else {
			self.pushSFSafariWeb(urlString: Constants.URLs.twitterURL)
		}
	}
	
	private func goToContributors() {
		let controller = self.pushContributorsScreen()
		self.navigationController?.pushViewController(controller, animated: true)
		self.tabBarController?.tabBar.isHidden = true
	}
	
    private func goToSendFeedback() {
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
	
	private func goToAppStore() {
		let urlString = "https://itunes.apple.com/app/id\(AppConstants.appID)"
		guard let url = URL(string: urlString) else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
	
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
