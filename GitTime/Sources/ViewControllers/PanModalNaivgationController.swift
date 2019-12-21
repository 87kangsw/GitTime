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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        log.verbose("DEINIT: \(self.className)")
    }
}

extension PanModalNaivgationController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        nil
    }
}
