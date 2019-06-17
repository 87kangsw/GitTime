//
//  Reusable.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
