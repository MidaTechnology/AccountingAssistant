//
//  ToastMessage.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27..
//
import Foundation

struct ToastMessage: Equatable {
    var id: UUID
    var isError: Bool
    var text: String
    
    init(_ id: UUID = UUID(), text: String) {
        self.id = id
        self.isError = false
        self.text = text
    }
    
    init(_ id: UUID = UUID(), localized: LocalizedStringResource) {
        self.id = id
        self.isError = false
        self.text = String(localized: localized)
    }
    
    init(_ id: UUID = UUID(), error: Error) {
        self.id = id
        self.isError = true
        self.text = error.localizedDescription
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
