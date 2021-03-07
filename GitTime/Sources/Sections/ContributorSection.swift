//
//  ContributorSection.swift
//  GitTime
//
//  Created by Kanz on 2020/10/27.
//

import RxDataSources

enum ContributorSection {
	case contributor([ContributorSectionItem])
}

extension ContributorSection: SectionModelType {
	
	var items: [ContributorSectionItem] {
		switch self {
		case .contributor(let items):
			return items
		}
	}
	
	init(original: ContributorSection, items: [ContributorSectionItem]) {
		switch original {
		case .contributor:
			self = .contributor(items)
		}
	}
}

enum ContributorSectionItem {
	case contributor(ContributorCellReactor)
}
