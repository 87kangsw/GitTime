//
//  SearchResultsSection.swift
//  GitTime
//
//  Created by Kanz on 11/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxDataSources

enum SearchResultsSection {
    case searchUsers([SearchResultsSectionItem])
    case seachRepositories([SearchResultsSectionItem])
    case recentSearchWords([SearchResultsSectionItem])
}

extension SearchResultsSection: SectionModelType {
    var items: [SearchResultsSectionItem] {
        switch self {
        case .searchUsers(let items):
            return items
        case .seachRepositories(let items):
            return items
        case .recentSearchWords(let items):
            return items
        }
    }
    
    init(original: SearchResultsSection, items: [SearchResultsSectionItem]) {
        switch original {
        case .searchUsers:
            self = .searchUsers(items)
        case .seachRepositories:
            self = .seachRepositories(items)
        case .recentSearchWords:
            self = .recentSearchWords(items)
        }
    }
}

enum SearchResultsSectionItem {
    case searchedUser(SearchUserCellReactor)
    case searchedRepository(SearchRepoCellReactor)
    case recentWord(SearchHistoryCellReactor)
}
