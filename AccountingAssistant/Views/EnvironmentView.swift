//
//  EnvironmentView.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//

import SwiftUI

struct EnvironmentView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("配置")
                .font(.title)
                .foregroundStyle(Color.aPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(Array(appStore.environment.keys), id: \.self) { key in
                VStack(spacing: 6) {
                    Text(key)
                        .font(.headline)
                        .foregroundStyle(Color.aPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        key,
                        text: Binding(
                            get: { appStore.environment[key] ?? "" },
                            set: { appStore.environment[key] = $0 }
                        )
                    )
                    .font(.body)
                    .foregroundStyle(Color.aPrimary)
                }
            }

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
        .onChange(of: appStore.environment) { _, _ in
            appStore.saveEnvs()
        }
    }
}

#Preview {
    EnvironmentView()
        .environment(AppStore())
        .frame(minWidth: 120, maxWidth: 240)
}

