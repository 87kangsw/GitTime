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
        
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        heightConstraint.constant = 0.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let tableView = self.superview as? UITableView {
            let headerHeight = tableView.tableHeaderView?.frame.height ?? 0.0
            heightConstraint.constant = tableView.frame.height - headerHeight
        } else {
            heightConstraint.constant = 300.0
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
