//
//  EmptyTableViewCell.swift
//  GitTime
//
//  Created by Kanz on 20/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

final class EmptyTableViewCell: BaseTableViewCell, View, CellType {

    typealias Reactor = EmptyTableViewCellReactor
     
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
		$0.font = .systemFont(ofSize: 15.0)
		$0.textColor = .title
		$0.textAlignment = .center
    }

	// MARK: - Initializing
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
		
		var height: CGFloat = 300.0
		
        if let tableView = self.superview as? UITableView {
            let headerHeight = tableView.tableHeaderView?.frame.height ?? 0.0
			height = tableView.frame.height - headerHeight
        }
		
		titleLabel.snp.updateConstraints { make in
			make.height.equalTo(height)
		}
		
    }

	override func addViews() {
		super.addViews()
		
		self.contentView.addSubview(titleLabel)
	}

	override func setupConstraints() {
		super.setupConstraints()
		
		titleLabel.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.leading.equalTo(16.0)
			make.trailing.equalTo(-16.0)
			make.height.equalTo(100.0)
		}
	}
	
    fileprivate func updateUI(_ state: Reactor.State) {
        titleLabel.text = state.type.noResultText
    }
    
    func bind(reactor: Reactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
