//
//  ActivityItemCell.swift
//  GitTime
//
//  Created by Kanz on 10/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class ActivityItemCell: BaseTableViewCell, View, CellType {
    
    typealias Reactor = ActivityItemCellReactor

    // MARK: - UI
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var repositoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = ""
        repositoryLabel.text = ""
        descriptionLabel.text = ""
        dateLabel.text = ""
    }
    
    fileprivate func configureUI() {
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2.0
        iconImageView.layer.masksToBounds = true
        iconImageView.contentMode = .center
        iconImageView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00)
        
        titleLabel.textColor = .title
        repositoryLabel.textColor = .subTitle
        descriptionLabel.textColor = .description
        dateLabel.textColor = .description
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        
        let iconImage = state.event.eventIconImage
        iconImageView.image = iconImage
        
        let actor = state.event.actor.name
        let eventMessage = state.event.eventMessage ?? ""
        titleLabel.text = "\(actor) \(eventMessage)"
        
        let repository = state.event.repo.name
        repositoryLabel.text = repository
        
        let description = state.event.description
        descriptionLabel.text = description ?? ""
        
        let date = state.event.createdAt
        let dateString = date.timeAgo()
        dateLabel.text = dateString
    }
    
    func bind(reactor: Reactor) {
        
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
    }
}
