//
//  UIView+Extensions.swift
//  GitTime
//
//  Created by Kanz on 2021/02/08.
//

import UIKit

extension UIView {
	func circleShape() {
		self.layer.cornerRadius = self.frame.height / 2.0
		self.layer.masksToBounds = true
	}
	
	func cornerRadius(_ radius: CGFloat) {
		self.layer.cornerRadius = radius
		self.layer.masksToBounds = true
	}
}
