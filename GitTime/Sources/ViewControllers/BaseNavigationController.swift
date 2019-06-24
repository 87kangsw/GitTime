//
//  BaseNavigationController.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    lazy private(set) var className: String = {
        return type(of: self).description().components(separatedBy: ".").last ?? ""
    }()
    
    // MARK: - Properties
    
    // MARK: - Initialize
    
    // MARK: Rx
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.hidesUnderLine(true)
        self.navigationBar.hideShadowImage()
        self.navigationBar.barTintColor = UIColor.white
    }
    
    deinit {
        log.verbose("DEINIT: \(self.className)")
    }
    
    // MARK: - Layout Constraints
    
    // MARK: - Configure
}
