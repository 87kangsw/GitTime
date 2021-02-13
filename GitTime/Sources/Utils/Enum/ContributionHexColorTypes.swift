//
//  ContributionHexColorTypes.swift
//  GitTime
//
//  Created by Kanz on 2020/10/30.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import Foundation

enum ContributionHexColorTypes: Int, CaseIterable {
    case level0 = 0
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    
    var hexString: String {
        switch self {
        case .level0:
            return "ebedf0"
        case .level1:
            return "9be9a8"
        case .level2:
            return "40c463"
        case .level3:
            return "30a14e"
        case .level4:
            return "216e39"
        }
    }
}
