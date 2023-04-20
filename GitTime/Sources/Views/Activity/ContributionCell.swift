//
//  ContributionCell.swift
//  GitTime
//
//  Created by Kanz on 14/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class ContributionCell: BaseCollectionViewCell, ReactorKit.View {
    
    typealias Reactor = ContributionCellReactor
    
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = .cellBackground
		self.contentView.backgroundColor = .cellBackground
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    func bind(reactor: Reactor) {
        
        reactor.state.map { $0.contribution }
            .subscribe(onNext: { [weak self] contribution in
                guard let self = self else { return }
                let color = UIColor(hexString: contribution.hexColor)
				self.contentView.backgroundColor = color
            }).disposed(by: self.disposeBag)
    }
}
