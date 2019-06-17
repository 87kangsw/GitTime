//
//  FollowTypes.swift
//  GitTime
//
//  Created by Kanz on 04/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

enum FollowTypes: CaseIterable {
    case followers
    case following
    
    var segmentTitle: String {
        switch self {
        case .followers:
            return "Followers"
        case .following:
            return "Following"
        }
    }
}
