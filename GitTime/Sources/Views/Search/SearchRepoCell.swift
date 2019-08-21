//
//  SearchRepoCell.swift
//  GitTime
//
//  Created by Kanz on 10/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SearchRepoCell: BaseTableViewCell, View, CellType {

    typealias Reactor = SearchRepoCellReactor
    
    // MARK: - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var totalStarLabel: UILabel!
    @IBOutlet weak var totalForkLabel: UILabel!
    @IBOutlet weak var languageNameLabel: UILabel!
    
    // MARK: - Properties
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        reset()
    }
    
    fileprivate func configureUI() {
    }
    
    fileprivate func reset() {
        languageNameLabel.text = ""
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let repoName = state.repo.name
        let authorName = state.repo.owner.name
        titleLabel.text = "\(authorName) / \(repoName)"
        
        let description = state.repo.description
        descLabel.text = description
        
        let totalStars = state.repo.starCount
        totalStarLabel.text = totalStars.formatUsingAbbrevation()
        let totalForks = state.repo.forkCount
        totalForkLabel.text = totalForks.formatUsingAbbrevation()
        
        let languageName = state.repo.language ?? ""
        languageNameLabel.text = languageName
    }
    
    func bind(reactor: Reactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
