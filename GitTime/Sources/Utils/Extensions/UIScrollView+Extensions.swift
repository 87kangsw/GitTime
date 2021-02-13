//
//  UIScrollView+Extensions.swift
//  GitTime
//
//  Created by Kanz on 2020/12/17.
//

import UIKit

extension UIScrollView {
//	func scrollToTop() {
//		if let tableView = self as? UITableView {
//			tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//		} else if let collectionView = self as? UICollectionView {
//			collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
//		} else {
//			self.setContentOffset(.zero, animated: true)
//		}
//	}
	
	func scrollToTop(_ animated: Bool) {
		var topContentOffset: CGPoint
		if #available(iOS 11.0, *) {
			topContentOffset = CGPoint(x: -safeAreaInsets.left, y: -safeAreaInsets.top)
		} else {
			topContentOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)
		}
		setContentOffset(topContentOffset, animated: animated)
	}
}
