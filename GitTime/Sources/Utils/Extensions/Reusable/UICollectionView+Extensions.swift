//
//  UICollectionView+Extensions.swift
//  GitTime
//
//  Created by Kanz on 17/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

extension UICollectionViewCell: Reusable {}

extension UICollectionView {
    
    final func register<T: UICollectionViewCell>(cellType: T.Type) {
        register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func registerNib<T: UICollectionViewCell>(cellType: T.Type) {
        let nib = UINib(nibName: cellType.reuseIdentifier, bundle: nil)
        register(nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
                + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                + "and that you registered the cell beforehand")
        }
        return cell
    }
}
