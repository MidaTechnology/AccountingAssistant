//
//  AccountingAssistantApp.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/26.
//

import SwiftUI
import SwiftData

@main
struct AccountingAssistantApp: App {
    @State private var appStore = AppStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appStore)
                .toast($appStore.toastMessage)
        }
        .modelContainer(for: [Accounting.self, AccountingAnalyzReport.self], inMemory: false)
        .defaultSize(CGSize(width: 860, height: 540))
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact(showsTitle: true))
    }
}
