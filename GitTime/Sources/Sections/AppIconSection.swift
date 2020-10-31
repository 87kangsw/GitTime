//
//  AppIconSection.swift
//  GitTime
//
//  Created by Kanz on 2020/10/28.
//

import RxDataSources

enum AppIconSection {
	case appIcon([AppIconSectionItem])
}

extension AppIconSection: SectionModelType {
	init(original: AppIconSection, items: [AppIconSectionItem]) {
		switch original {
		case .appIcon:
			self = .appIcon(items)
		}
	}
	
	var items: [AppIconSectionItem] {
		switch self {
		case .appIcon(let items):
			return items
		}
	}
}

enum AppIconSectionItem {
	case appIcon(AppIconCellReactor)
}
