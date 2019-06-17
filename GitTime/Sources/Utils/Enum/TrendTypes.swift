//
//  TrendTypes.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

enum TrendTypes: CaseIterable {
    case repositories
    case developers
    
    var segmentTitle: String {
        switch self {
        case .repositories:
            return "Repositories"
        case .developers:
            return "Developers"
        }
    }
}
