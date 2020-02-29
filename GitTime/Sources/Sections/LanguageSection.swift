//
//  LanguageSection.swift
//  GitTime
//
//  Created by Kanz on 03/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxDataSources

enum LanguageSection {
    case allLanguage([LanguageSectionItem])
    case languages([LanguageSectionItem])
    case emptyFavorites([LanguageSectionItem])
}

extension LanguageSection: SectionModelType {
    
    var items: [LanguageSectionItem] {
        switch self {
        case .allLanguage(let items):
            return items
        case .languages(let items):
            return items
        case .emptyFavorites(let items):
            return items
        }
    }
    
    init(original: LanguageSection, items: [LanguageSectionItem]) {
        switch original {
        case .allLanguage:
            self = .allLanguage(items)
        case .languages:
            self = .languages(items)
        case .emptyFavorites:
            self = .emptyFavorites(items)
        }
    }
}

enum LanguageSectionItem {
    case allLanguage(LanguageListCellReactor)
    case languages(LanguageListCellReactor)
    case emptyFavorites(FavoriteLanguageTableViewCellReactor)
}
