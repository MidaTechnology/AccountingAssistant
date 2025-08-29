//
//  Date+Extension.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/12.
//

import Foundation

enum DatePeriod {
    case week(offset: Int = 0)
    case month(offset: Int = 0)
    case year(offset: Int = 0)
}

extension Date {
    func dateFormatting() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let date = Date(timeIntervalSince1970: self.timeIntervalSince1970)
        return formatter.string(from: date)
    }
    
    var timeSecondsSince1970: Int64 {
        return Int64(self.timeIntervalSince1970)
    }
    
    func relativeDateFormatting(_ date: Date = Date(), locale: Locale = Locale(identifier: "zh_CN")) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        formatter.locale = locale
        return formatter.localizedString(for: self, relativeTo: date)
    }
    
    func dateRangeForPeriod(_ period: DatePeriod) -> (start: Date, end: Date) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        switch period {
        case .week(let offset):
            guard let offsetDate = calendar.date(byAdding: .weekOfYear, value: offset, to: self) else {
                return (self, self)
            }
            guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: offsetDate) else {
                return (self, self)
            }
            guard let endOfWeek = calendar.date(byAdding: .second, value: -1, to: weekInterval.end) else {
                return (self, self)
            }
            return (weekInterval.start, endOfWeek)
        case .month(let offset):
            guard let offsetDate = calendar.date(byAdding: .month, value: offset, to: self) else {
                return (self, self)
            }
            guard let monthInterval = calendar.dateInterval(of: .month, for: offsetDate) else {
                return (self, self)
            }
            guard let endOfMonth = calendar.date(byAdding: .second, value: -1, to: monthInterval.end) else {
                return (self, self)
            }
            return (monthInterval.start, endOfMonth)
        case .year(let offset):
            guard let offsetDate = calendar.date(byAdding: .year, value: offset, to: self) else {
                return (self, self)
            }
            guard let yearInterval = calendar.dateInterval(of: .year, for: offsetDate) else {
                return (self, self)
            }
            guard let endOfYear = calendar.date(byAdding: .second, value: -1, to: yearInterval.end) else {
                return (self, self)
            }
            return (yearInterval.start, endOfYear)
        }
    }
}
