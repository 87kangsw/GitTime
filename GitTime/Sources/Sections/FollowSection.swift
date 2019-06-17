//
//  FollowSection.swift
//  GitTime
//
//  Created by Kanz on 04/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxDataSources

enum FollowSection {
    case followUsers([FollowSectionItem])
}

extension FollowSection: SectionModelType {
    var items: [FollowSectionItem] {
        switch self {
        case .followUsers(let items):
            return items
        }
    }
    
    init(original: FollowSection, items: [FollowSectionItem]) {
        switch original {
        case .followUsers:
            self = .followUsers(items)
        }
    }
}

enum FollowSectionItem {
    case followUsers(FollowUserCellReactor)
}
