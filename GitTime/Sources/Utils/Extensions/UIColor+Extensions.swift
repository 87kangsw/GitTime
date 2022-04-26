//
//  UIColor+Extensions.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

extension UIColor {
	convenience init(hexString: String, alpha: CGFloat = 1.0) {
		var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
		
		if hexFormatted.hasPrefix("#") {
			hexFormatted = String(hexFormatted.dropFirst())
		}
		
		assert(hexFormatted.count == 6, "Invalid hex code used.")
		
		var rgbValue: UInt64 = 0
		Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
		
		self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
				  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
				  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
				  alpha: alpha)
    }
}

extension UIColor {
    
    // MARK: - View
    static var background: UIColor {
        return UIColor(named: "Background") ?? .clear
    }
    
    static var lightBackground: UIColor {
        return UIColor(named: "LightBackground") ?? .clear
    }
    
    static var cellBackground: UIColor {
        return UIColor(named: "CellBackground") ?? .clear
    }
    
    static var navigationTint: UIColor {
        return UIColor(named: "NavigationTint") ?? .clear
    }
    
    static var tableSectionHeader: UIColor {
        return UIColor(named: "TableSectionHeader") ?? .clear
    }
    
    static var underLine: UIColor {
        return UIColor(named: "UnderLine") ?? .clear
    }
    
    static var loginButtonBackground: UIColor {
        return UIColor(named: "LoginButtonBackground") ?? .clear
    }
    
    static var invertBackground: UIColor {
        return UIColor(named: "InvertBackground") ?? .clear
    }
    
    // Text
    static var title: UIColor {
        return UIColor(named: "Title") ?? .clear
    }
    
    static var subTitle: UIColor {
        return UIColor(named: "SubTitle") ?? .clear
    }
    
    static var description: UIColor {
        return UIColor(named: "Description") ?? .clear
    }
    
    static var loginButtonTitle: UIColor {
        return UIColor(named: "LoginButtonTitle") ?? .clear
    }
    
    static var invertTitle: UIColor {
        return UIColor(named: "InvertTitle") ?? .clear
    }
}
