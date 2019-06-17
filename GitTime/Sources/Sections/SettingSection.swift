//
//  SettingSection.swift
//  GitTime
//
//  Created by Kanz on 05/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxDataSources

enum SettingSection {
    case aboutMe([SettingSectionItem])
    case aboutApp([SettingSectionItem])
    case logout([SettingSectionItem])
}

extension SettingSection: SectionModelType {
    
    var items: [SettingSectionItem] {
        switch self {
        case .aboutMe(let items):
            return items
        case .aboutApp(let items):
            return items
        case .logout(let items):
            return items
        }
    }
    
    init(original: SettingSection, items: [SettingSectionItem]) {
        switch original {
        case .aboutMe:
            self = .aboutMe(items)
        case .aboutApp:
            self = .aboutApp(items)
        case .logout:
            self = .logout(items)
        }
    }
}

enum SettingSectionItem {
    case myProfile(SettingUserProfileCellReactor)
    case githubRepo(SettingItemCellReactor)
    case acknowledgements(SettingItemCellReactor)
    case contact(SettingItemCellReactor)
    case rateApp(SettingItemCellReactor)
    case version(SettingItemCellReactor)
    case logout(SettingLogoutCellReactor)
}
