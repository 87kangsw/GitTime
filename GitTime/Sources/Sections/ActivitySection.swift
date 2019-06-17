//
//  ActivitySection.swift
//  GitTime
//
//  Created by Kanz on 07/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxDataSources

enum ActivitySection {
    case contribution([ActivitySectionItem])
    case activities([ActivitySectionItem])
}

extension ActivitySection: SectionModelType {
    
    var items: [ActivitySectionItem] {
        switch self {
        case .contribution(let items):
            return items
        case .activities(let items):
            return items
        }
    }
    
    init(original: ActivitySection, items: [ActivitySectionItem]) {
        switch original {
        case .contribution:
            self = .contribution(items)
        case .activities:
            self = .activities(items)
        }
    }
}

enum ActivitySectionItem {
    case contribution(ActivityContributionCellReactor)
    case createEvent(ActivityItemCellReactor)
    case watchEvent(ActivityItemCellReactor)
    case pullRequestEvent(ActivityItemCellReactor)
    case pushEvent(ActivityItemCellReactor)
    case forkEvent(ActivityItemCellReactor)
    case issuesEvent(ActivityItemCellReactor)
    case issueCommentEvent(ActivityItemCellReactor)
    case releaseEvent(ActivityItemCellReactor)
    case pullRequestReviewCommentEvent(ActivityItemCellReactor)
    case publicEvent(ActivityItemCellReactor)
}
