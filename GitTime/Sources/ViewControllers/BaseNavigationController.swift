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
//        self.navigationBar.backgroundColor = UIColor.white
//        self.navigationBar.tintColor = UIColor.orange
        self.navigationBar.barTintColor = UIColor.white
//        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    deinit {
        log.verbose("DEINIT: \(self.className)")
    }
    
    // MARK: - Layout Constraints
    
    // MARK: - Configure
}
