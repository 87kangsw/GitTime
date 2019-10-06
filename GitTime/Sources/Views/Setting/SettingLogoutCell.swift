//
//  SettingLogoutCell.swift
//  GitTime
//
//  Created by Kanz on 05/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SettingLogoutCell: BaseTableViewCell, View, CellType {

    typealias Reactor = SettingLogoutCellReactor
    
    @IBOutlet weak var logoutLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    fileprivate func configureUI() {
        logoutLabel.text = "Logout"
        
        self.backgroundColor = .lightBackground
        self.contentView.backgroundColor = .lightBackground
    }
    
    func bind(reactor: Reactor) {
        
    }
}
