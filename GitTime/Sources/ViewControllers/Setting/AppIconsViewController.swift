//
//  AppIconsViewController.swift
//  GitTime
//
//  Created Kanz on 2020/10/27.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import ReusableKit

final class AppIconsViewController: BaseViewController, ReactorKit.View {
    
    typealias Reactor = AppIconsViewReactor
    
    private struct Reusable {
		static let appIconCell = ReusableCell<AppIconCell>()
    }
    
    // MARK: Properties
    
	// MARK: Views
	private let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
		$0.rowHeight = 70.0
		$0.register(Reusable.appIconCell)
		$0.backgroundColor = .systemGroupedBackground
	}
	
    // MARK: Initializing
    init(reactor: AppIconsViewReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Application Icon"
    }
    
    override func addViews() {
        super.addViews()
		self.view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
    }
    
    // MARK: Binding
    func bind(reactor: AppIconsViewReactor) {
        
		let dataSource = self.dataSource()
		reactor.state.map { $0.sections }
			.bind(to: self.tableView.rx.items(dataSource: dataSource))
			.disposed(by: self.disposeBag)
		
		tableView.rx.itemSelected(dataSource: dataSource)
			.subscribe(onNext: { [weak self] sectionItem in
				guard let self = self else { return }
				switch sectionItem {
				case .appIcon(let cellReactor):
					log.debug(cellReactor.currentState.icon)
					self.selectIcon(cellReactor.currentState.icon.plistIconName)
				}
			}).disposed(by: self.disposeBag)
    }
	
	private func dataSource() -> RxTableViewSectionedReloadDataSource<AppIconSection> {
		return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
			switch sectionItem {
			case .appIcon(let cellReactor):
				let cell = tableView.dequeue(Reusable.appIconCell, for: indexPath)
				cell.reactor = cellReactor
				return cell
			}
		})
	}
	
	private func selectIcon(_ iconName: String) {
		if UIApplication.shared.supportsAlternateIcons {
			log.debug(UIApplication.shared.supportsAlternateIcons)
			
			UIApplication.shared.setAlternateIconName(iconName) { [weak self] error in
				guard let self = self else { return }
				if let error = error {
					log.error(error)
				} else {
					UserDefaultsConfig.appIconName = iconName
					self.reactor?.action.onNext(.setSelectedAppIcon(iconName))
				}
			}
		}
	}
}
