//
//  CellType.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

protocol CellType: class {
    static var reuseIdentifier: String { get }
    static var cellFromNib: Self { get }
}

extension CellType where Self: UITableViewCell {
    static var cellFromNib: Self {
        guard let cell = Bundle.main.loadNibNamed(String(describing: Self.self), owner: nil, options: nil)?.first as? Self else {
            return Self()
        }
        return cell
    }
    
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension CellType where Self: UICollectionViewCell {
    static var cellFromNib: Self {
        guard let cell = Bundle.main.loadNibNamed(String(describing: Self.self), owner: nil, options: nil)?.first as? Self else {
            return Self()
        }
        return cell
    }
    
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
