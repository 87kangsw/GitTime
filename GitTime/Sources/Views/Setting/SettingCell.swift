//
//  SettingCell.swift
//  GitTime
//
//  Created by Kanz on 2020/10/26.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class SettingCell: BaseTableViewCell, ReactorKit.View {
    
    typealias Reactor = SettingCellReactor
    
    // MARK: - Initializing
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.accessoryType = .disclosureIndicator
		self.backgroundColor = .secondarySystemGroupedBackground
		self.contentView.backgroundColor = .secondarySystemGroupedBackground
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - UI Setup
    
    // MARK: - Binding
    func bind(reactor: SettingCellReactor) {

		reactor.state.map { $0.settingType.menuTitle }
			.subscribe(onNext: { [weak self] title in
				guard let self = self else { return }
				self.textLabel?.text = title
			}).disposed(by: self.disposeBag)
		
		reactor.state.map { $0.settingType }
			.subscribe(onNext: { [weak self] type in
				guard let self = self else { return }
				self.textLabel?.textColor = (type == .logout) ? .systemRed : .title
			}).disposed(by: self.disposeBag)
    }
}
