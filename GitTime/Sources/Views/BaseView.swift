//
//  BaseView.swift
//  GitTime
//
//  Created by Kanz on 2020/11/04.
//

import UIKit

import RxSwift

class BaseView: UIView {
	
	// MARK: add Views,Layout Constraints
	private(set) var didSetupConstraints = false
	
	var disposeBag = DisposeBag()
	
	override var safeAreaInsets: UIEdgeInsets {
		if #available(iOS 11.0, *) {
			guard let window = UIApplication.shared.windows.first else { return super.safeAreaInsets }
			
			return window.safeAreaInsets
		} else {
			return .zero
		}
	}
	
	init() {
		super.init(frame: .zero)
		self.addViews()
		self.setNeedsUpdateConstraints()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		log.debug("DEINIT: \(type(of: self).description().components(separatedBy: ".").last ?? "")")
	}
	
	override public func layoutSubviews() {
		if !self.didSetupConstraints {
			self.setupConstraints()
			self.didSetupConstraints = true
		}
		super.layoutSubviews()
	}
	
	func addViews() {
		// Override point
	}
	
	func setupConstraints() {
		// Override point
	}
}
