//
//  SettingSection.swift
//  GitTime
//
//  Created by Kanz on 05/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxDataSources

enum SettingSection {
	case appPreference([SettingSectionItem])
	case about([SettingSectionItem])
	case privacy([SettingSectionItem])
	case authors([SettingSectionItem])
	case logout([SettingSectionItem])
}

extension SettingSection: SectionModelType {
    
    var items: [SettingSectionItem] {
        switch self {
        case .appPreference(let items):
            return items
        case .about(let items):
            return items
        case .privacy(let items):
            return items
		case .authors(let items):
			return items
		case .logout(let items):
			return items
        }
    }
    
    init(original: SettingSection, items: [SettingSectionItem]) {
        switch original {
		case .appPreference:
			self = .appPreference(items)
		case .about:
			self = .about(items)
		case .privacy:
			self = .privacy(items)
		case .authors:
			self = .authors(items)
		case .logout:
			self = .logout(items)
		}
    }
}

enum SettingSectionItem {
	case appIcon(SettingCellReactor)
	
	case repo(SettingCellReactor)
	case opensource(SettingCellReactor)
	case recommend(SettingCellReactor)
	case appReview(SettingCellReactor)
	
	case privacy(SettingCellReactor)
	
	case author(SettingCellReactor)
	case contributors(SettingCellReactor)
	case shareFeedback(SettingCellReactor)
	
	case logout(SettingCellReactor)
}
