//
//  Date+Extensions.swift
//  GitTime
//
//  Created by Kanz on 11/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

extension Date {
    // https://gist.github.com/minorbug/468790060810e0d29545
    func timeAgo(numericDates: Bool = true) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now
        
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfMonth, .month, .year, .second]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        
        let year = components.year ?? 0
        let month = components.month ?? 0
        let weekOfMonth = components.weekOfMonth ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        switch (year, month, weekOfMonth, day, hour, minute, second) {
        case (let year, _, _, _, _, _, _) where year >= 2: return "\(year) years ago"
        case (let year, _, _, _, _, _, _) where year == 1 && numericDates: return "1 year ago"
        case (let year, _, _, _, _, _, _) where year == 1 && !numericDates: return "Last year"
        case (_, let month, _, _, _, _, _) where month >= 2: return "\(month) months ago"
        case (_, let month, _, _, _, _, _) where month == 1 && numericDates: return "1 month ago"
        case (_, let month, _, _, _, _, _) where month == 1 && !numericDates: return "Last month"
        case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth >= 2: return "\(weekOfMonth) weeks ago"
        case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth == 1 && numericDates: return "1 week ago"
        case (_, _, let weekOfMonth, _, _, _, _) where weekOfMonth == 1 && !numericDates: return "Last week"
        case (_, _, _, let day, _, _, _) where day >= 2: return "\(day) days ago"
        case (_, _, _, let day, _, _, _) where day == 1 && numericDates: return "1 day ago"
        case (_, _, _, let day, _, _, _) where day == 1 && !numericDates: return "Yesterday"
        case (_, _, _, _, let hour, _, _) where hour >= 2: return "\(hour) hours ago"
        case (_, _, _, _, let hour, _, _) where hour == 1 && numericDates: return "1 hour ago"
        case (_, _, _, _, let hour, _, _) where hour == 1 && !numericDates: return "An hour ago"
        case (_, _, _, _, _, let minute, _) where minute >= 2: return "\(minute) minutes ago"
        case (_, _, _, _, _, let minute, _) where minute == 1 && numericDates: return "1 minute ago"
        case (_, _, _, _, _, let minute, _) where minute == 1 && !numericDates: return "A minute ago"
        case (_, _, _, _, _, _, let second) where second >= 3: return "\(second) seconds ago"
        default: return "Just now"
        }
    }
}
