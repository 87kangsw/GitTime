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
    
    /// There is a bug when trying to go back to previous view controller in a navigation controller
    /// on iOS 11, a scroll view in the previous screen scrolls weirdly. In order to get this fixed,
    /// we have to set the scrollView's `contentInsetAdjustmentBehavior` property to `.never` on
    /// `viewWillAppear()` and set back to the original value on `viewDidAppear()`.
    private var scrollViewOriginalContentInsetAdjustmentBehaviorRawValue: Int?
    
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
