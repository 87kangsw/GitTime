//
//  TrendSection.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxDataSources

enum TrendSection {
    case repo([TrendSectionItem])
    case developer([TrendSectionItem])
}

extension TrendSection: SectionModelType {
    
    var items: [TrendSectionItem] {
        switch self {
        case .repo(let items):
            return items
        case .developer(let items):
            return items
        }
    }
    
    init(original: TrendSection, items: [TrendSectionItem]) {
        switch original {
        case .repo:
            self = .repo(items)
        case .developer:
            self = .developer(items)
        }
    }
}

enum TrendSectionItem {
    case trendingRepos(TrendingRepositoryCellReactor)
    case trendingDevelopers(TrendingDeveloperCellReactor)
//    case empty(EmptyTableViewCellReactor)
}
