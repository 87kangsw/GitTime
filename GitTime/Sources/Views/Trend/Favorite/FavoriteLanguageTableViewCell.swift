//
//  FavoriteLanguageTableViewCell.swift
//  GitTime
//
//  Created by Kanz on 2020/01/31.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class FavoriteLanguageTableViewCell: BaseTableViewCell, View, CellType {

    // MARK: - Reactor
    typealias Reactor = FavoriteLanguageTableViewCellReactor
    
    // MARK: - UI
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    
    // MARK: - Initializing
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - UI Setup
    fileprivate func configureUI() {
        colorView.layer.cornerRadius = 5.0
        colorView.layer.masksToBounds = true
        languageLabel.font = .systemFont(ofSize: 14.0)
        favoriteButton.isSelected = true
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let languageName = state.favoriteLanguage.name
        languageLabel.text = languageName
        
        let colorName = state.favoriteLanguage.color
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

extension Reactive where Base: FavoriteLanguageTableViewCell {
    var favoriteTapped: Observable<FavoriteLanguage> {
        return base.favoriteButton.rx.tap
            .map { self.base.reactor?.currentState.favoriteLanguage }
            .filterNil()
    }
    
    var languageTapped: Observable<FavoriteLanguage> {
        return base.languageButton.rx.tap
            .map { self.base.reactor?.currentState.favoriteLanguage }
            .filterNil()
    }
}
