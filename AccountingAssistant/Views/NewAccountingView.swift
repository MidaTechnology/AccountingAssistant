//
//  NewAccountingView.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//

import SwiftUI
import SwiftData

struct NewAccountingView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var date: Date = Date()
    @State var category: AccountingCategory = .Other
    @State var amount: Decimal = Decimal(0)
    @State var desc: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("新账单")
                    .font(.title)
                    .foregroundStyle(Color.aPrimary)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.aSecondary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            VStack(spacing: 6) {
                Text("时间")
                    .font(.headline)
                    .foregroundStyle(Color.aPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                DatePicker(selection: $date) {
                }
                .pickerStyle(.automatic)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack(spacing: 6) {
                Text("类别")
                    .font(.headline)
                    .foregroundStyle(Color.aPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Menu {
                    ForEach(AccountingCategory.allCases, id: \.self) { c in
                        Button {
                            category = c
                        } label: {
                            Text(c.text)
                                .font(.body)
                                .foregroundStyle(Color.aPrimary)
                        }
                    }
                } label: {
                    Text(category.text)
                        .font(.body)
                        .foregroundStyle(Color.aPrimary)
                }
                .menuStyle(.button)
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            VStack(spacing: 6) {
                Text("金额")
                    .font(.headline)
                    .foregroundStyle(Color.aPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Stepper(
                    value: Binding(get: { amount.toFloat() }, set: { amount = Decimal(Double($0)) }),
                    step: 0.01
                ) {
                    TextField(
                        "0.00",
                        text: Binding(
                            get: { amount.formatString(2, group: .never) },
                            set: { amount = Decimal(string: $0) ?? Decimal(0) }
                        )
                    )
                    .font(.body)
                    .foregroundStyle(Color.aPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack(spacing: 6) {
                Text("描述")
                    .font(.headline)
                    .foregroundStyle(Color.aPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $desc)
                    .frame(minHeight: 64, maxHeight: 128)
                    .foregroundStyle(Color.aPrimary)
                    .font(.body)
                    .padding(6)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.never)
                    .background(Color.aSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack {
                Spacer()
                Button {
                    saveAccounting()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.aPrimary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.top, 32)
        }
        .padding(16)
        .frame(maxWidth: 320)
    }
    
    private func saveAccounting() {
        let accounting = Accounting(date: date, category: category, amount: amount, desc: desc)
        appStore.newAccountingWithContenxt(modelContext, accounting: accounting)
        dismiss()
    }
}

#Preview {
    NewAccountingView()
        .environment(AppStore())
        .modelContainer(for: [Accounting.self, AccountingAnalyzReport.self])
        .frame(minWidth: 120, maxWidth: 240)
}

