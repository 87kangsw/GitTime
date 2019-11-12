//
//  SearchResults.swift
//  GitTime
//
//  Created by Kanz on 09/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct SearchResults<T: ModelType>: ModelType {
    let totalCount: Int
    let items: [T]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
