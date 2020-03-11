//
//  UIViewController+Extensions.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import SafariServices
import UIKit

import PanModal

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

// MARK: - Pan Modal
extension UIViewController {
    /*
    func presentPanModalWeb(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        let nav = PanModalNaivgationController(rootViewController: safariVC)
        presentPanModal(nav)
    }
    */
    func presentModalWeb(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        GitTimeAnalytics.shared.logEvent(key: "web", parameters: nil)
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .formSheet
        self.present(safariVC, animated: true, completion: nil)
    }
}
