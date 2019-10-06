//
//  UIColor+Extensions.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
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
