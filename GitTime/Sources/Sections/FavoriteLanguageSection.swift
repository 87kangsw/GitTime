//
//  FavoriteLanguageSection.swift
//  GitTime
//
//  Created by Kanz on 2020/02/29.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import RxDataSources

enum FavoriteLanguageSection {
    case favorite([FavoriteLanguageSectionItem])
}

extension FavoriteLanguageSection: SectionModelType {
    var items: [FavoriteLanguageSectionItem] {
        switch self {
        case .favorite(let items):
            return items
        }
    }
    
    init(original: FavoriteLanguageSection, items: [FavoriteLanguageSectionItem]) {
        switch original {
        case .favorite:
            self = .favorite(items)
        }
    }
}

enum FavoriteLanguageSectionItem {
    case favorite(FavoriteLanguageTableViewCellReactor)
}
