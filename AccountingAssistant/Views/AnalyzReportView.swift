//
//  AnalyzReportView.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//

import SwiftUI
import MarkdownUI

struct AnalyzReportView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) var dismiss
    
    @State var report: AccountingAnalyzReport
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                Markdown(report.content)
                    .markdownTextStyle {
                        FontSize(12)
                        ForegroundColor(Color.aPrimary)
                    }
                    .markdownTextStyle(\.link) {
                        FontSize(12)
                        ForegroundColor(Color.accent)
                    }
                    .markdownBlockStyle(\.codeBlock) { configuration in
                        configuration.label
                            .fixedSize(horizontal: false, vertical: true)
                            .relativeLineSpacing(.em(0.15))
                            .relativePadding(.horizontal, length: .rem(1))
                            .markdownTextStyle {
                                FontFamilyVariant(.monospaced)
                                FontSize(.em(0.64))
                            }
                            .padding(8)
                            .background(Color.yellow.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .markdownMargin(top: .zero, bottom: .em(1))
                    }
                    .markdownSoftBreakMode(.lineBreak)
                    .textSelection(.enabled)
                    .tint(Color.accent)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)

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
        }
        .padding(16)
    }
}

#Preview {
    @Previewable @State var report = AccountingAnalyzReport(
        content: "# 消费分析与建议\n\n根据您提供的数据，我们将对2025年8月的消费情况进行分析，并基于目前可用的信息提供一些消费管理和攒钱建议。\n\n## 8月消费分析\n\n| 类别    | 金额      |\n|---------|-----------|\n| 餐饮    | -206.40 元 |\n| 娱乐    | -288.00 元 |\n| 交通    | -253.00 元 |\n| 还款    | -8,000.00 元 |\n| 其它支出 | -288.00 元 |\n| 薪水    | +8,888.00 元 |\n| 其它收入| +100.00 元 |\n\n### 总结\n- **总收入**：+8,988.00 元\n- **总支出**：-9,035.40 元\n- **收入减去支出（净收入）**：-47.40 元\n\n### 主要观察\n1. **欠款还款**：您8月的主要支出项体现在还款上，占到了总支出的绝大部分。确保这种还款计划在您的预算之内。\n2. **餐饮与娱乐花费**：相较于还款而言，餐饮和娱乐支出相对较低。此策略在您处于还款或攒钱阶段时，可持续。\n3. **交通支出**：看上去合理，但根据个人需求，可以考虑交通费是否有降低空间。\n\n## 建议\n\n### 制定预算\n- **还款计划优先处理**：如果有高利率欠款，优先还清这类借款以减少未来不必要的利息支出。\n- **设立每月预算**：根据收到的净收入，设定个人每月的固定支出和可变支出预算。\n\n### 攒钱建议\n- **紧急储蓄基金**：建立一个涵盖3-6个月生活开支的储蓄基金。每月可尝试自动转账一定比例的收入至储蓄账户。\n- **考虑投资**：如果有余钱即使不多，也可以考虑低风险投资以获得被动收入。例如，指数基金或高利率储蓄账户。\n\n### 支出控制\n- **监控不必要的支出**：如果可能，进一步减少娱乐和非必需消费，尤其是在计划还款或蓄积资金时。\n- **交通费优化**：如有可能，可通过合乘出行、公共交通或步行的方式减少交通费用。\n\n以上建议提供了一个大体思路，具体的实施还需根据个人生活方式和长期财务目标进行调整。希望这些建议可以帮助您优化财务管理，实现经济上的稳步增长。"
    )
    AnalyzReportView(
        report: report
    )
    .environment(AppStore())
    .frame(minWidth: 320, maxWidth: 480, maxHeight: 360)
}

