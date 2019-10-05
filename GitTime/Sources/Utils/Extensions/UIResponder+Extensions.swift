//
//  UIResponder+Extensions.swift
//  GitTime
//
//  Created by Kanz on 05/10/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

extension UIResponder {

    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
}
