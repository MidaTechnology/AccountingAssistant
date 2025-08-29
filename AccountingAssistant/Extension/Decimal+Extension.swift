//
//  Decimal+Extension.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/12.
//

import Foundation

extension Decimal {
    func formatString(_ precision: Int = 2, group: Decimal.FormatStyle.Configuration.Grouping = .automatic) -> String {
        let value = self.formatted(.number.precision(.fractionLength(precision)).grouping(group).rounded(rule: .towardZero))
        return "\(value)"
    }
    
    func toFloat() -> Float {
        return NSDecimalNumber(decimal: self).floatValue
    }
}
