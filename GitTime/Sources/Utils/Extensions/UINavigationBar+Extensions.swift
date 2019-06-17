//
//  UINavigationBar+Extensions.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func hidesUnderLine(_ hidden: Bool) {
        self.setValue(hidden, forKey: "hidesShadow")
    }
    
    func hideShadowImage() {
        self.shadowImage = UIImage()
    }
}
