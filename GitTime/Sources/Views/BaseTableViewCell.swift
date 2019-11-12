//
//  BaseTableViewCell.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import RxSwift

class BaseTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .cellBackground
        self.contentView.backgroundColor = .cellBackground
        selectionStyle = .none
    }
}
