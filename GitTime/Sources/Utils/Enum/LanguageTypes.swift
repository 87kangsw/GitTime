//
//  LanguageType.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

enum LanguageTypes: String, CaseIterable, Codable {
    case programming
    case data
    case markup
    case prose
    case all
    
    static func indexToType(_ index: Int) -> LanguageTypes {
        switch index {
        case 0:
            return .programming
        case 1:
            return .data
        case 2:
            return .markup
        case 3:
            return .prose
        default:
            return .programming
        }
    }
    
    static func typeToIndex(_ type: LanguageTypes) -> Int {
        switch type {
        case .programming:
            return 0
        case .data:
            return 1
        case .markup:
            return 2
        case .prose:
            return 3
        default:
            return 0
        }
    }
    
    func buttonTitle() -> String {
        switch self {
        case.all:
            return "All Languages"
        default:
            return self.rawValue
        }
    }
	
	func iconName() -> String {
		switch self {
		case .programming:
			return "languageProgramming"
		case .data:
			return "languageData"
		case .markup:
			return "languageMarkup"
		case .prose:
			return "languageProse"
		case .all:
			return ""
		}
	}
}
