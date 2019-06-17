//
//  Contribution.swift
//  GitTime
//
//  Created by Kanz on 13/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct Contribution: ModelType {
    let date: String
    let contribution: Int
    let hexColor: String
    
    enum CodingKeys: String, CodingKey {
        case date
        case contribution
        case hexColor
    }
}

struct ContributionInfo: ModelType {
    let count: Int
    let contributions: [Contribution]
    
    enum CodingKeys: String, CodingKey {
        case count
        case contributions
    }
}
