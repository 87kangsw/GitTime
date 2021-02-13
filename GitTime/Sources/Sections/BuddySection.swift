//
//  BuddySection.swift
//  GitTime
//
//  Created by Kanz on 2020/11/06.
//

import RxDataSources

enum BuddySection {
	case buddys([BuddySectionItem])
}

extension BuddySection: SectionModelType {
	var items: [BuddySectionItem] {
		switch self {
		case .buddys(let items):
			return items
		}
	}
	
	init(original: BuddySection, items: [BuddySectionItem]) {
		switch original {
		case .buddys(let items):
			self = .buddys(items)
		}
	}
}

enum BuddySectionItem {
	case daily(BuddyDailyCellReactor)
	case weekly(BuddyYearlyCellReactor)
}
