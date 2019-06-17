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
}
