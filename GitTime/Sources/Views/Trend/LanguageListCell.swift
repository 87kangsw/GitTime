//
//  LanguageListCell.swift
//  GitTime
//
//  Created by Kanz on 31/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class LanguageListCell: BaseTableViewCell, View, CellType {

    typealias Reactor = LanguageListCellReactor
        
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let languageName = state.language.name
        languageLabel.text = languageName
        languageLabel.font = state.language.type == .all ?
            .boldSystemFont(ofSize: 15.0) : .systemFont(ofSize: 14.0)
        
        let colorName = state.language.color
        if !colorName.isEmpty {
            let color = UIColor(hexString: colorName)
            colorView.backgroundColor = color
        } else {
            colorView.backgroundColor = .clear
        }
    }
    
    func bind(reactor: Reactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
