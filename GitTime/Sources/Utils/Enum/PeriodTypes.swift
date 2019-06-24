//
//  PeriodTypes.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

// since: daily, weekly or monthly, default to daily.
enum PeriodTypes: String, CaseIterable {
    case daily
    case weekly
    case monthly
    
    func buttonTitle() -> String {
        switch self {
        case .daily:
            return "Today"
        case .weekly:
            return "This week"
        case .monthly:
            return "This month"
        }
    }
    
    func querySting() -> String {
        switch self {
        case .daily:
            return "daily"
        case .weekly:
            return "weekly"
        case .monthly:
            return "monthly"
        }
    }
    
    func periodText() -> String {
        switch self {
        case .daily:
            return "today"
        case .weekly:
            return "this week"
        case .monthly:
            return "this month"
        }
    }
}
