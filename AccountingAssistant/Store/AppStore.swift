//
//  AppStore.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//
import SwiftUI
import SwiftData
import OpenAI

@Observable
class AppStore {
    // Env
    var environment: [String: String] = Constants.environment
    // Toast
    var toastMessage: ToastMessage?
    // Accountings
    var accountings: [Accounting] = []
    var analyzReport: AccountingAnalyzReport?
    
    init() {
        if let envData = UserDefaults.standard.data(forKey: "environment"),
           let env = try? JSONDecoder().decode([String: String].self, from: envData) {
            self.environment.keys.forEach { key in
                self.environment[key] = env[key] ?? ""
            }
        }
    }
    
    /// 提示信息
    /// - Parameter error: 错误信息
    @MainActor
    func publish(_ error: Error) {
        toastMessage = ToastMessage(error: error)
    }
    
    /// 保存系统环境变量
    func saveEnvs() {
        if let envData = try? JSONEncoder().encode(environment) {
            UserDefaults.standard.set(envData, forKey: "environment")
        }
    }
}

extension AppStore {
    /// 加载本地记录
    /// - Parameter context: 数据存储 Context
    @MainActor
    func accountingsWithContenxt(_ context: ModelContext) {
        // 账单
        let descriptor = FetchDescriptor<Accounting> (
            sortBy: [SortDescriptor(\Accounting.date, order: .reverse)]
        )
        let accountings = (try? context.fetch(descriptor)) ?? []
        self.accountings = accountings
        
        // 报告
        let reportDescriptor = FetchDescriptor<AccountingAnalyzReport> (
            sortBy: [SortDescriptor(\AccountingAnalyzReport.date, order: .reverse)]
        )
        let reports = (try? context.fetch(reportDescriptor)) ?? []
        self.analyzReport = reports.first
    }
    
    /// 创建账单信息
    /// - Parameters:
    ///   - context: 数据存储 Context
    ///   - accounting: 账单
    /// - Returns: 新账单
    @MainActor
    func newAccountingWithContenxt(_ context: ModelContext, accounting: Accounting) {
        context.insert(accounting)
        let index = self.accountings.firstIndex(where: { $0.date < accounting.date}) ?? 0
        self.accountings.insert(accounting, at: index)
    }
    
    /// 更新账单信息
    /// - Parameters:
    ///   - context: 数据存储 Context
    ///   - accounting: 账单
    /// - Returns: 新账单
    @MainActor
    func updateAccountingWithContenxt(_ context: ModelContext, accounting: Accounting) {
        // Reorder
        if let a = self.accountings.first(where: { $0.id < accounting.id }), a.date != accounting.date {
            self.accountings.sort(by: { $0.date > $1.date })
        }
    }
    
    /// 删除单个账单信息
    /// - Parameter context: 数据存储 Context
    @MainActor
    func deleteAccountingWithContenxt(_ context: ModelContext, accounting: Accounting) {
        context.delete(accounting)
        self.accountings.removeAll(where: { $0.id == accounting.id })
    }
    
    /// AI 生成账单
    /// - Parameters:
    ///   - context: 数据存储 Context
    ///   - text: 用户输入信息
    ///   - completion: 完成回调
    @MainActor
    func accountingsWithContext(_ context: ModelContext, text: String, completion: (() -> Void)? = nil) {
        guard let openAIApiKey = environment["openAIApiKey"], !openAIApiKey.isEmpty else {
            self.publish(AccountingError.custom("Invalid OpenAI APIKey"))
            return
        }
        let configuration = OpenAI.Configuration(token: openAIApiKey, parsingOptions: .fillRequiredFieldIfKeyNotFound)
        let openAI = OpenAI(configuration: configuration)
        let query = ChatQuery(
            messages: [
                .init(role: .system, content: "你是一个记账助手，将用户输入信息进行分类，无需翻译，字段包含分类、金额、描述，其中金额不包含单位并且根据描述判断是否是支出加上-")!,
                .init(role: .user, content: text)!,
            ],
            model: .gpt4_o,
            responseFormat: .jsonSchema(
                .init(
                    name: "accounting_schema",
                    description: "A collection of accounting records",
                    schema: .dynamicJsonSchema(AccountingsResp.schema),
                    strict: true
                )
            )
        )
        Task {
            do {
                let result = try await openAI.chats(query: query)
                guard let jsonData = result.choices.first?.message.content?.data(using: .utf8) else {
                    throw AccountingError.custom("Invalid Data")
                }
                let response = try JSONDecoder().decode(AccountingsResp.self, from: jsonData)
                let newAccountings = response.accountings.map({
                    Accounting(
                        category: AccountingCategory(rawValue: $0.category) ?? .Other,
                        amount: $0.amount,
                        desc: $0.desc
                    )
                })
                newAccountings.forEach {
                    context.insert($0)
                }
                self.accountings.insert(contentsOf: newAccountings.reversed(), at: 0)
                completion?()
            } catch let error {
                self.publish(error)
                completion?()
            }
        }
    }
    
    /// AI 账单分析
    /// - Parameters:
    ///   - text: 用户输入信息
    ///   - context: 数据存储 Context
    @MainActor
    func accountingsAnalyzingWithContext(_ context: ModelContext, completion: (() -> Void)? = nil) {
        guard !accountings.isEmpty else {
            self.publish(AccountingError.custom("Empty Data"))
            completion?()
            return
        }
        // 获取当年每月的账单信息
        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let month = Calendar.current.component(.month, from: now)
        var text = "\(year)年账单\n"
        for i in 0..<month {
            text.append("\(month - i)月份：\n")
            // 支出
            let expenseS = self.accountingSummariesWithKind(.expense, date: now, period: .month(offset: -i))
            expenseS.forEach { s in
                text.append("  \(s.category.text): \(s.total.formatString(2)) 元\n")
            }
            // 收入
            let incomeS = self.accountingSummariesWithKind(.income, date: now, period: .month(offset: -i))
            incomeS.forEach { s in
                text.append("  \(s.category.text): +\(s.total.formatString(2)) 元\n")
            }
        }
        // AI 建议
        guard let openAIApiKey = environment["openAIApiKey"], !openAIApiKey.isEmpty else {
            self.publish(AccountingError.custom("Invalid OpenAI APIKey"))
            return
        }
        let configuration = OpenAI.Configuration(token: openAIApiKey, parsingOptions: .fillRequiredFieldIfKeyNotFound)
        let openAI = OpenAI(configuration: configuration)
        
        let query = ChatQuery(
            messages: [
                .init(role: .system, content: "你是一个记账助手，根据用户近几个月份的消费情况，进行消费分析。给出合理的的消费习惯、攒钱计划等建议，格式使用Markdown输出。")!,
                .init(role: .user, content: text)!,
            ],
            model: .gpt4_o,
            responseFormat: .text
        )
        Task {
            do {
                let result = try await openAI.chats(query: query)
                guard let content = result.choices.first?.message.content else {
                    throw AccountingError.custom("Invalid Data")
                }
                
                let report = AccountingAnalyzReport(content: content)
                context.insert(report)
                
                self.analyzReport = report
                completion?()
            } catch let error {
                self.publish(error)
                completion?()
            }
        }
    }
    
    /// 归类账单信息
    /// - Parameters:
    ///   - kind: 类别
    ///   - date: 参考日期
    ///   - period: 时间区间
    /// - Returns: 归类数据集合
    func accountingSummariesWithKind(_ kind: AccountingsSummary.Kind, date: Date, period: DatePeriod) -> [AccountingsSummary] {
        let (startDate, endDate) = date.dateRangeForPeriod(period)
        let filterAccountings = self.accountings.filter({
            $0.date >= startDate && $0.date <= endDate && $0.isIncome == (kind == .income)
        })
        
        let grouped =  Dictionary(grouping: filterAccountings, by: { $0.category })
        var summary: [AccountingsSummary] = []
        for (category, items) in grouped {
            summary.append(AccountingsSummary(
                category: category,
                accountings: items
            ))
        }
        return summary.sorted(by: { $0.category.index <= $1.category.index })
    }
}
