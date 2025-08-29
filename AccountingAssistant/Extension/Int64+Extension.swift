//
//  Int64+Extension.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/5/24.
//

import Foundation

extension Int64 {
    func toDate() -> Date {
        return Date(timeIntervalSince1970: Double(self))
    }
}
