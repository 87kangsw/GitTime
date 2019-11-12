//
//  SettingItemCell.swift
//  GitTime
//
//  Created by Kanz on 05/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SettingItemCell: BaseTableViewCell, View, CellType {

    typealias Reactor = SettingItemCellReactor
    
    // MARK: - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    fileprivate func configureUI() {
        
        self.backgroundColor = .lightBackground
        self.contentView.backgroundColor = .lightBackground
        
        titleLabel.font = .systemFont(ofSize: 14.0)
        subTitleLabel.font = .systemFont(ofSize: 12.0)
        subTitleLabel.textColor = .description
    }
    
    func bind(reactor: SettingItemCellReactor) {
                
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.titleLabel?.text = state.title
                self.subTitleLabel?.text = state.subTitle
            })
            .disposed(by: self.disposeBag)
    }
}
