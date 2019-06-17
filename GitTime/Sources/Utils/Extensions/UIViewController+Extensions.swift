//
//  UIViewController+Extensions.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

extension UIViewController {
    static func instantiateByStoryboard<T>() -> T {
        let className = String(describing: self)
        let storyboard = UIStoryboard(name: className, bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() as? T else {
            fatalError("The initialViewController of '\(storyboard)' is not of class '\(self)'")
        }
        return viewController
    }
    
    func navigationWrap() -> BaseNavigationController {
        return BaseNavigationController(rootViewController: self)
    }
}
