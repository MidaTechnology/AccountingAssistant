//
//  ContentView.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .frame(minWidth: 200, maxWidth: 300)
        } detail: {
            DetailView()
                .frame(minWidth: 480, maxWidth: 720)
        }
        .onAppear {
            appStore.accountingsWithContenxt(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
        .modelContainer(for: [Accounting.self, AccountingAnalyzReport.self])
        .frame(width: 860, height: 540)
}
