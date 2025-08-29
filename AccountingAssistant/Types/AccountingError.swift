//
//  AccountingError.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//

import Foundation

enum AccountingError: LocalizedError {
    case unknown
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .custom(let message):
            return message
        }
    }
}
