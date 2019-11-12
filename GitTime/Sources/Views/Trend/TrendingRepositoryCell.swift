//
//  TrendingRepositoryCell.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class TrendingRepositoryCell: BaseTableViewCell, View, CellType {
    
    typealias Reactor = TrendingRepositoryCellReactor
    
    // MARK: - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var totalStarLabel: UILabel!
    @IBOutlet weak var totalForkLabel: UILabel!
    @IBOutlet weak var periodStarLabel: UILabel!
    @IBOutlet weak var languageColorView: UIView!
    @IBOutlet weak var languageNameLabel: UILabel!
    
    // MARK: - Properties
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    fileprivate func configureUI() {
        languageColorView.layer.cornerRadius = 5.0 / 2
        languageColorView.layer.masksToBounds = true
        languageColorView.backgroundColor = .clear
    }
    
    fileprivate func reset() {
        languageColorView.backgroundColor = .clear
        languageNameLabel.text = ""
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let repoName = state.repoName
        let authorName = state.author
        titleLabel.text = "\(authorName) / \(repoName)"
        
        let description = state.description
        descLabel.text = description
        
        let totalStars = state.totalStars
        totalStarLabel.text = totalStars.formatUsingAbbrevation()
        let totalForks = state.totalForks
        totalForkLabel.text = totalForks.formatUsingAbbrevation()
        
        let languageName = state.language ?? ""
        languageNameLabel.text = languageName
        if let colorName = state.languageColor, !colorName.isEmpty {
            let languageColor = UIColor(hexString: colorName)
            languageColorView.backgroundColor = languageColor
        }
        
        let periodStar = state.periodStar
        let period = state.period.periodText()
        periodStarLabel.text = "\(periodStar.commaString()) stars \(period)"
    }
    
    func bind(reactor: Reactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                 self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
