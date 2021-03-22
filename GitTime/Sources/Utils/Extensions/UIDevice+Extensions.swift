//
//  UIDevice+Extensions.swift
//  GitTime
//
//  Created by Kanz on 2021/03/22.
//

import Foundation
import UIKit

extension UIDevice {
	public class var isPhone: Bool {
		return UIDevice.current.userInterfaceIdiom == .phone
	}
	
	public class var isPad: Bool {
		return UIDevice.current.userInterfaceIdiom == .pad
	}
}
