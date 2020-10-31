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

	private(set) var didSetupConstraints = false
	
	var disposeBag = DisposeBag()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.addViews()
		self.layoutSubviews()
		
		self.backgroundColor = .cellBackground
		self.contentView.backgroundColor = .cellBackground
		selectionStyle = .none
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		log.debug("DEINIT: \(type(of: self).description().components(separatedBy: ".").last ?? "")")
	}
	
	override func layoutSubviews() {
		if !self.didSetupConstraints {
			self.setupConstraints()
			self.didSetupConstraints = true
		}
		super.layoutSubviews()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		disposeBag = DisposeBag()
	}
	
	func addViews() {}
	
	func setupConstraints() {}
}
/*
extension BaseTableViewCell {
    override var isHighlighted: Bool {
        didSet {
            let duration = isHighlighted ? 0.45 : 0.4
            let transform = isHighlighted ?
                CGAffineTransform(scaleX: 0.96, y: 0.96) : CGAffineTransform.identity
            let animations = {
                self.transform = transform
            }
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0.0,
                           options: [.allowUserInteraction, .beginFromCurrentState],
                           animations: animations,
                           completion: nil)
        }
    }
}
*/
