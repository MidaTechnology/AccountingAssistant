//
//  UpdateAccountingView.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//

import SwiftUI
import SwiftData

struct UpdateAccountingView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State var accounting: Accounting
    
    var body: some View {
        VStack(spacing: 16) {
            Text("更新账单")
                .font(.title)
                .foregroundStyle(Color.aPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 6) {
                Text("时间")
                    .font(.headline)
                    .foregroundStyle(Color.aPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                DatePicker(selection: Binding(get: { accounting.date }, set: { accounting.date = $0 })) {
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
                    ForEach(AccountingCategory.allCases, id: \.self) { category in
                        Button {
                            accounting.category = category
                        } label: {
                            Text(category.text)
                                .font(.body)
                                .foregroundStyle(Color.aPrimary)
                        }
                    }
                } label: {
                    Text(accounting.category.text)
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
                    value: Binding(get: { accounting.amount.toFloat() }, set: { accounting.amount = Decimal(Double($0)) }),
                    step: 0.01
                ) {
                    TextField(
                        "0.00",
                        text: Binding(
                            get: { accounting.amount.formatString(2, group: .never) },
                            set: { accounting.amount = Decimal(string: $0) ?? Decimal(0) }
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
                TextEditor(text: Binding(get: { accounting.desc }, set: { accounting.desc = $0 }))
                    .frame(minHeight: 64, maxHeight: 128)
                    .foregroundStyle(Color.aPrimary)
                    .font(.body)
                    .padding(6)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.never)
                    .background(Color.aSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Button {
                deleteAccounting()
            } label: {
                Text("删除")
                    .font(.body)
                    .foregroundStyle(Color.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .scaledToFit()
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
    
    private func deleteAccounting() {
        appStore.deleteAccountingWithContenxt(modelContext, accounting: accounting)
        dismiss()
    }
}

#Preview {
    UpdateAccountingView(
        accounting: .init(category: .Entertainment, amount: Decimal(100), desc: "Game")
    )
    .modelContainer(for: [Accounting.self, AccountingAnalyzReport.self])
    .frame(minWidth: 120, maxWidth: 240)
}

