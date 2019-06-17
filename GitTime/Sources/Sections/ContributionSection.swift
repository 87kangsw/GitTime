//
//  ContributionSection.swift
//  GitTime
//
//  Created by Kanz on 17/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxDataSources

enum ContributionSection {
    case contribution([ContributionSectionItem])
}

extension ContributionSection: SectionModelType {
    var items: [ContributionSectionItem] {
        switch self {
        case .contribution(let items):
            return items
        }
    }
    
    init(original: ContributionSection, items: [ContributionSectionItem]) {
        switch original {
        case .contribution:
            self = .contribution(items)
        }
    }
}

enum ContributionSectionItem {
    case contribution(ContributionCellReactor)
}
