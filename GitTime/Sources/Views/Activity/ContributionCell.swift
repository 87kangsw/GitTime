//
//  ContributionCell.swift
//  GitTime
//
//  Created by Kanz on 14/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class ContributionCell: UICollectionViewCell, View, CellType {
    
    typealias Reactor = ContributionCellReactor
    var disposeBag = DisposeBag()
    
    // MARK: - UI
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func bind(reactor: Reactor) {
        
        reactor.state.map { $0.contribution }
            .subscribe(onNext: { [weak self] contribution in
                guard let self = self else { return }
                let color = UIColor(hexString: contribution.hexColor)
                self.bgView.backgroundColor = color
            }).disposed(by: self.disposeBag)
    }
}
