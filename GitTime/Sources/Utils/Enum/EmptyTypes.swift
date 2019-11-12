//
//  EmptyTypes.swift
//  GitTime
//
//  Created by Kanz on 20/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

enum EmptyTypes: CaseIterable {
    case activity
    case trendingRepo
    case trendingDeveloper
    case follower
    case following
    case searchUser
    case searchRepo
    case recentSearchWord
    
    var noResultText: String {
        switch self {
        case .activity:
            return "You don't have any activities yet."
        case .trendingRepo:
            return "It looks like we don't have any trending repositories."
        case .trendingDeveloper:
            return "It looks like we don't have any trending developers."
        case .follower:
            return "You don't have any followers yet."
        case .following:
            return "You aren’t following anybody."
        case .searchUser:
            return "We couldn’t find any users matching words"
        case .searchRepo:
            return "We couldn’t find any repositories matching words"
        case .recentSearchWord:
            return "You don't have any histories yet."
        }
    }
}
