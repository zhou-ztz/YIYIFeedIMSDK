//
//  Calendar+Extension.swift
//  YIYIFeedIMSDK
//
//  Created by dong on 2024/11/29.
//
import Foundation
import SwiftDate

private let gregorianCalendar = Calendar(identifier: .gregorian)

extension Calendar {
    
    static func startDayOfMonth(in month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(calendar: gregorianCalendar,
                                            year: year,
                                            month: month,
                                            day: 1)
        var adjustedWeekday = gregorianCalendar.component(.weekday, from: dateComponents.date!)
        
        if adjustedWeekday == 0 {
            return 7
        }
        
        return adjustedWeekday - 1
    }

    static func numberOfDays(in month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(calendar: gregorianCalendar,
                                            year: year,
                                            month: month)
        
        guard let date = dateComponents.date else { return 0 }
        
        return gregorianCalendar.component(.day,
                                  from: gregorianCalendar.date(byAdding: DateComponents(month: 1, day: -1),
                                                               to: date)!)
    }
    
}

private let dateFormatter = DateFormatter()

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            return "\(secondsAgo) \("secondsago".localized)"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) \("minutes_ago".localized)"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) \("hours_ago".localized)"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) \("days_ago".localized)"
        }
        
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter.string(from: date)
    }
}
