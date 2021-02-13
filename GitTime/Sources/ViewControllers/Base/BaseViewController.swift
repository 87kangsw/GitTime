//
//  BaseViewController.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import RxSwift

class BaseViewController: UIViewController {
	
	lazy private(set) var className: String = {
		return type(of: self).description().components(separatedBy: ".").last ?? ""
	}()
	
	// MARK: - Properties

	// MARK: - Initialize
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required convenience init?(coder aDecoder: NSCoder) {
		self.init()
	}
	
	// MARK: - Rx
	
	var disposeBag = DisposeBag()
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		self.view.backgroundColor = .white
		self.addViews()
		self.view.setNeedsUpdateConstraints()
	}

	deinit {
		log.verbose("DEINIT: \(self.className)")
	}
	
	// MARK: add Views,Layout Constraints
	private(set) var didSetupConstraints = false
	
	override func updateViewConstraints() {
		if !self.didSetupConstraints {
			self.setupConstraints()
			self.didSetupConstraints = true
		}
		super.updateViewConstraints()
	}
	
	// MARK: Override Functions
	func addViews() {}
	
	func setupConstraints() {}
}
