//
//  PanModalNaivgationController.swift
//  GitTime
//
//  Created by Kanz on 2019/12/18.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import PanModal
 
class PanModalNaivgationController: UINavigationController {
    lazy private(set) var className: String = {
        return type(of: self).description().components(separatedBy: ".").last ?? ""
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.prefersLargeTitles = false
        self.navigationBar.hidesUnderLine(true)
        self.navigationBar.hideShadowImage()
        self.navigationBar.barTintColor = .navigationTint
    }
    
    deinit {
        log.verbose("DEINIT: \(self.className)")
    }
}

extension PanModalNaivgationController: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var panScrollable: UIScrollView? {
        return (topViewController as? PanModalPresentable)?.panScrollable
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(200)
    }
    var anchorModalToLongForm: Bool {
        return false
    }
}
