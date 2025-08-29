//
//  Item.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/26.
//

import SwiftUI
import SwiftData
import JSONSchema

enum AccountingCategory: String, Codable, CaseIterable {
    case Food
    case Entertainment
    case Transportation
    case Salary
    case Repayment
    case Rent
    case Other
    
    var text: String {
        switch self {
        case .Food:
            return "餐饮"
        case .Entertainment:
            return "娱乐"
        case .Transportation:
            return "交通"
        case .Salary:
            return "薪水"
        case .Repayment:
            return "还款"
        case .Rent:
            return "租金"
        case .Other:
            return "其它"
        }
    }
    
    var index: Int {
        switch self {
        case .Food:
            return 0
        case .Entertainment:
            return 1
        case .Transportation:
            return 2
        case .Salary:
            return 3
        case .Repayment:
            return 4
        case .Rent:
            return 5
        case .Other:
            return 6
        }
    }
    
    var color: Color {
        switch self {
        case .Food:
            return .accent
        case .Entertainment:
            return .red
        case .Transportation:
            return .green
        case .Salary:
            return .purple
        case .Repayment:
            return .cyan
        case .Rent:
            return .yellow
        case .Other:
            return .gray
        }
    }
}

@Model
final class Accounting: Hashable {
    @Attribute(.unique)
    var id: UUID
    var date: Date
    var category: AccountingCategory
    var amount: Decimal
    var desc: String
    
    var isIncome: Bool {
        return amount >= Decimal(0)
    }
    
    init(id: UUID = UUID(), date: Date = Date(), category: AccountingCategory, amount: Decimal, desc: String) {
        self.id = id
        self.date = date
        self.category = category
        self.amount = amount
        self.desc = desc
    }
}

struct AccountingsSummary: Identifiable, Hashable {
    enum Kind: String, CaseIterable {
        case expense
        case income
        
        var text: String {
            switch self {
            case .income:
                return "收入"
            case .expense:
                return "支出"
            }
        }
    }
    
    var id: String {
        return category.rawValue
    }
    
    var category: AccountingCategory
    var accountings: [Accounting]
    
    var total: Decimal {
        return accountings.reduce(into: Decimal(0), { $0 = $0 + $1.amount })
    }
}

@Model
final class AccountingAnalyzReport: Hashable {
    @Attribute(.unique)
    var id: UUID
    var date: Date
    var content: String
    
    init(id: UUID = UUID(), date: Date = Date(), content: String) {
        self.id = id
        self.date = date
        self.content = content
    }
}

struct AccountingsResp: Decodable {
    struct Item: Decodable {
        var category: String
        var amount: Decimal
        var desc: String
        
        enum CodingKeys: String, CodingKey {
            case category
            case amount
            case desc = "description"
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.category = try container.decode(String.self, forKey: .category)
            self.amount = try container.decode(Decimal.self, forKey: .amount)
            self.desc = try container.decode(String.self, forKey: .desc)
        }
    }
    var accountings: [AccountingsResp.Item]
    
    static var schema: JSONSchema {
        return JSONSchema.object(
            description: "A collection of accounting records",
            properties: [
                "accountings": .array(
                    description: "List of accounting objects",
                    items: .object(
                        properties: [
                            "category": .enum(
                                description: "The detailed description of the transaction",
                                values: AccountingCategory.allCases.map({ .string($0.rawValue) })
                            ),
                            "amount": .number(description: "The monetary amount of the accounting"),
                            "description": .string(description: "The detailed description of the accounting")
                        ],
                        required: ["category", "amount", "description"],
                        additionalProperties: .boolean(false)
                    )
                )
            ],
            required: ["accountings"],
            additionalProperties: .boolean(false)
        )
    }
}
