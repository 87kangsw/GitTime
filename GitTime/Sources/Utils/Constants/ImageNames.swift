//
//  Constants.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

protocol ImageNames {
    var imageName: String { get }
}

// MARK: - TabBar Icon
enum TabBarImages: String, ImageNames {
    var imageName: String {
        return self.rawValue
    }
    case activity = "activity"
    case activityFilled = "activityFill"
    case trending = "trending"
    case trendingFilled = "trendingFill"
    case follow = "follow"
    case followFilled = "followFill"
    case setting = "setting"
    case settingFilled = "settingFill"
    case search = "search"
}

// MARK: - NavigationBar Icon
enum NavBarImages: String, ImageNames {
    var imageName: String {
        return self.rawValue
    }
    
    case filter = "navFilter"
}

enum EventImages: String, ImageNames {
    var imageName: String {
        return self.rawValue
    }
    
    case createEventBranch
    case createEventRepo
    case createEventTag
    case forkEvent
    case issueCommentEvent
    case issuesEvnet
    case pullRequestEvent
    case pushEvent
    case releaseEvent
    case watchEvent
    case publicEvent
}

enum SearchTypeImages: String, ImageNames {
    var imageName: String {
        return self.rawValue
    }
    
    case users = "languageData"
    case repositories = "settingFill"
}
