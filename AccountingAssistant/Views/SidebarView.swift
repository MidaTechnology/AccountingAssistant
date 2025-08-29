//
//  SidebarView.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.modelContext) private var modelContext
    
    @State var selectedAccounting: Accounting?
    @State var isNewPresented: Bool = false
    
    var body: some View {
        VStack(spacing: 6) {
            Text("AI 记账")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            HStack {
                Text("最近账单")
                    .font(.headline)
                Spacer()
                Button {
                    isNewPresented.toggle()
                } label: {
                    Image(systemName: "plus")
                        .padding(6)
                }
                .buttonStyle(.plain)
                
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
            
            ScrollViewReader { proxy in
                List {
                    ForEach(appStore.accountings, id: \.self) { accounting in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack (spacing: 2) {
                                Text(accounting.date.relativeDateFormatting())
                                    .foregroundStyle(Color.aPrimary)
                                    .font(.body)
                                Spacer()
                                Text(accounting.category.text)
                                    .foregroundStyle(accounting.category.color)
                                    .font(.caption)
                                accounting.category.color
                                    .frame(width: 2, height: 10)
                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                            }
                            HStack(spacing: 4) {
                                Text(accounting.desc)
                                    .foregroundStyle(Color.aSecondary)
                                    .font(.caption)
                                Spacer()
                                Text(accounting.amount.formatString())
                                    .foregroundStyle(Color.aPrimary)
                                    .font(.caption)
                            }
                        }
                        .id(accounting)
                        .listRowSeparator(.hidden)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.aBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            selectedAccounting = accounting
                        }
                    }
                }
                .listStyle(.plain)
                .contentMargins(.top, 0, for: .scrollContent)
                .scrollContentBackground(.hidden)
                .onChange(of: appStore.accountings) { _, _ in
                    guard let anchorId = appStore.accountings.first else { return }
                    withAnimation {
                        proxy.scrollTo(anchorId, anchor: .top)
                    }
                }
            }
        }
        .refreshable {
            
        }
        .sheet(item: $selectedAccounting) { accounting in
            UpdateAccountingView(accounting: accounting)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(12)
        }
        .sheet(isPresented: $isNewPresented) {
            NewAccountingView()
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(12)
        }
    }
}

#Preview {
    SidebarView()
        .environment(AppStore())
        .modelContainer(for: [Accounting.self, AccountingAnalyzReport.self])
        .frame(minWidth: 120, maxWidth: 240)
}

