//
//  ReactorBased.swift
//  GitTime
//
//  Created by Kanz on 21/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

protocol ReactorBased: class {
    
}

extension ReactorBased where Self: StoryboardView & UIViewController {
    static func instantiate(withReactor reactor: Reactor) -> Self {
        let className = NSStringFromClass(Self.classForCoder()).components(separatedBy: ".").last!
        let storyboard = UIStoryboard(name: className, bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
            fatalError()
        }
        viewController.reactor = reactor
        return viewController
    }
}
