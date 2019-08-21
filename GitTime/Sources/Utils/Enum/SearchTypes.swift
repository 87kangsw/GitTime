//
//  SearchTypes.swift
//  GitTime
//
//  Created by Kanz on 10/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

enum SearchTypes: Int, CaseIterable {
    case users
    case repositories
    
    var segmentTitle: String {
        switch self {
        case .users:
            return "Users"
        case .repositories:
            return "Repositories"
        }
    }

    var placeHolderText: String {
        switch self {
        case .users:
            return "Input a query for user search.."
        case .repositories:
            return "Input a query for repository search.."
        }
    }
}
