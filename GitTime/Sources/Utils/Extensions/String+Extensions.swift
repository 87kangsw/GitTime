//
//  String+Extensions.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var striped: String {
        return replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Dates
extension String {
	func convertDateFormattedString(_ from: String = "YYYY-MM-dd", format: String) -> String {
		
		let formatter = DateFormatter()
		formatter.dateFormat = from
		
		guard let date = formatter.date(from: self) else { return "" }

		formatter.dateFormat = format
		
		return formatter.string(from: date)
	}
}
