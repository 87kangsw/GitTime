//
//  BaseCollectionCell.swift
//  GitTime
//
//  Created by Kanz on 2020/10/19.
//

import UIKit

import RxSwift

class BaseCollectionViewCell: UICollectionViewCell {
	
	private(set) var didSetupConstraints = false
	
	var disposeBag = DisposeBag()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addViews()
		self.backgroundColor = .cellBackground
		self.contentView.backgroundColor = .cellBackground
	}
	
	required init?(coder: NSCoder) {
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
