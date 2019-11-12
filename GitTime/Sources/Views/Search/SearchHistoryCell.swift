//
//  SearchHistoryCell.swift
//  GitTime
//
//  Created by Kanz on 05/10/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SearchHistoryCell: BaseTableViewCell, View, CellType {

    typealias Reactor = SearchHistoryCellReactor
    
    // MARK: - UI
    @IBOutlet weak var searchTextLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Properties
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    fileprivate func configureUI() {
        
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let history = state.history
        
        let text = history.text
        searchTextLabel.text = text
    }
    
    func bind(reactor: Reactor) {
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}

extension Reactive where Base: SearchHistoryCell {
    var deleteButtonTap: Observable<(IndexPath?, String?)> {
        return base.deleteButton.rx.tap
            .map { _ -> (IndexPath?, String?) in
                return (self.base.indexPath, self.base.reactor?.currentState.history.text)
        }
    }
}
