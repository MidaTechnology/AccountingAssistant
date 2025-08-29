//
//  DetailView.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//



import SwiftUI
import Charts
import SwiftData

struct PieChartView: View {
    @State var title: String
    @State var summaries: [AccountingsSummary]
    
    var body: some View {
        Chart(summaries) { item in
            SectorMark(
                angle: .value(item.category.rawValue, max(item.total.magnitude, Decimal(0.1))),
                innerRadius: .ratio(0.7),
                angularInset: 1
            )
            .foregroundStyle(item.category.color)
        }
        .chartLegend(position: .bottom, alignment: .center, spacing: 16)
        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: summaries)
        .padding()
        .overlay {
            ZStack {
                if summaries.isEmpty {
                    Circle()
                        .stroke(
                            Color.aSecondary,
                            style: StrokeStyle(
                                lineWidth: 2,
                                lineCap: .round,
                                lineJoin: .round,
                                dash: [5, 5]
                            )
                        )
                        .padding(16)
                }
                VStack {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(Color.aPrimary)
                        .fontWeight(.semibold)
                    Text(summaries.reduce(into: Decimal(0), { $0 += $1.total }).formatString(2))
                        .font(.callout)
                        .foregroundStyle(Color.aPrimary)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct DetailView: View {
    @Environment(AppStore.self) var appStore
    @Environment(\.modelContext) private var modelContext
    @State private var isEnvironmentPresented: Bool = false
    @State private var isShowRandomMenu: Bool = false
    
    @State private var text: String = ""
    @State private var placeholder: String = "说一说今天的消费情况吧"
    @FocusState private var isFocused: Bool
    @State private var isSubmiting: Bool = false
    @State private var isAnalyzing: Bool = false
    @State private var isViewAnalyzReport: Bool = false
    
    @State private var summaryKinds = AccountingsSummary.Kind.allCases
    @State private var summaryKind: AccountingsSummary.Kind = .expense
    @State private var weekSummaries: [AccountingsSummary] = []
    @State private var monthSummaries: [AccountingsSummary] = []
    @State private var yearSummaries: [AccountingsSummary] = []
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Picker(selection: $summaryKind) {
                    ForEach(summaryKinds, id: \.self) { c in
                        Text(c.text)
                            .tag(c)
                    }
                } label: {
                }
                .frame(maxWidth: 120)
                
                Spacer()
                
                ForEach(yearSummaries) { summary in
                    HStack(spacing: 2) {
                        summary.category.color
                            .frame(width: 2, height: 10)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                        Text(summary.category.text)
                            .foregroundStyle(Color.aSecondary)
                            .font(.callout)
                    }
                }
            }
            .pickerStyle(.segmented)
            .padding()
            HStack {
                PieChartView(title: "周", summaries: weekSummaries)
                    .id(weekSummaries)
                PieChartView(title: "月", summaries: monthSummaries)
                    .id(monthSummaries)
                PieChartView(title: "年", summaries: yearSummaries)
                    .id(yearSummaries)
            }
            .frame(height: 180)
            
            VStack(spacing: 2) {
                HStack(spacing: 0) {
                    Spacer()
                    if isAnalyzing {
                        ProgressView()
                            .scaleEffect(0.6)
                            .progressViewStyle(.circular)
                            .tint(Color.aPrimary)
                        Text("分析中...")
                            .font(.callout)
                            .foregroundStyle(Color.aPrimary)
                    } else {
                        Button {
                            analyzeAccounting()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "wand.and.sparkles.inverse")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16)
                                Text("AI 分析")
                                    .font(.callout)
                            }
                            .foregroundStyle(Color.accent)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                if appStore.analyzReport != nil {
                    Button("查看分析") {
                        isViewAnalyzReport.toggle()
                    }
                    .buttonStyle(.plain)
                    .font(.callout)
                    .foregroundStyle(Color.aSecondary)
                }
            }
            
            Spacer()
            
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $text)
                            .foregroundStyle(Color.aPrimary)
                            .font(.body)
                            .padding(6)
                            .scrollContentBackground(.hidden)
                            .focused($isFocused)
                            .scrollDisabled(true)
                            .disabled(isSubmiting)
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundStyle(Color.gray)
                                .font(.body)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 12)
                        }
                    }
                    .frame(maxHeight: 120)
                    
                    HStack {
                        Spacer()
                        if isSubmiting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(.circular)
                                .tint(Color.accent)
                        } else {
                            Button {
                                submitAccounting()
                            } label: {
                                Image(systemName: "photo")
                                    .padding(8)
                                    .foregroundStyle(Color.white)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .background(text.isEmpty ? Color.aSecondaryBackground : Color.accent)
                            .clipShape(Circle())
                            .disabled(text.isEmpty)
                            .hidden()
                            
                            Button {
                                submitAccounting()
                            } label: {
                                Image(systemName: "highlighter")
                                    .padding(8)
                                    .foregroundStyle(Color.white)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .background(text.isEmpty ? Color.aSecondaryBackground : Color.accent)
                            .clipShape(Circle())
                            .disabled(text.isEmpty)
                        }
                    }
                }
            }
            .padding(6)
            .background(Color.aBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
        .toolbar {
            Spacer()
            Button {
                isShowRandomMenu.toggle()
            } label: {
                Image(systemName: "dice")
            }
            .popover(isPresented: $isShowRandomMenu, attachmentAnchor: .point(.center), arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        randomText()
                        isShowRandomMenu.toggle()
                    } label: {
                        Text("随机消费文案")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.aPrimary)
                            .padding(12)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        randomAccountings()
                        isShowRandomMenu.toggle()
                    } label: {
                        Text("随机消费记录")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.aPrimary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(8)
            }
            Button {
                isEnvironmentPresented.toggle()
            } label: {
                Image(systemName: "gearshape")
            }
        }
        .sheet(isPresented: $isEnvironmentPresented) {
            EnvironmentView()
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(12)
        }
        .sheet(isPresented: $isViewAnalyzReport) {
            AnalyzReportView(
                report: appStore.analyzReport!
            )
            .frame(maxWidth: 560, maxHeight: 360)
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(12)
        }
        .onAppear {
            getData()
        }
        .onChange(of: summaryKind) { _, _ in
            getData()
        }
        .onChange(of: appStore.accountings) { _, _ in
            getData()
        }
    }
    
    private func randomText() {
        text = Mock.randomAccountingText()
    }
    
    private func randomAccountings() {
        let list = Mock.randomAccountings()
        list.forEach { l in
            modelContext.insert(l)
        }
        appStore.accountingsWithContenxt(modelContext)
    }
    
    private func getData() {
        let now = Date()
        withAnimation {
            weekSummaries = appStore.accountingSummariesWithKind(summaryKind, date: now, period: .week())
            monthSummaries = appStore.accountingSummariesWithKind(summaryKind, date: now, period: .month())
            yearSummaries = appStore.accountingSummariesWithKind(summaryKind, date: now, period: .year())
        }
    }
    
    private func submitAccounting() {
        isSubmiting = true
        appStore.accountingsWithContext(modelContext, text: text){
            isSubmiting = false
        }
    }
    
    private func analyzeAccounting() {
        isAnalyzing = true
        appStore.accountingsAnalyzingWithContext(modelContext){
            isAnalyzing = false
        }
    }
}

#Preview {
    DetailView()
        .modelContainer(for: [Accounting.self, AccountingAnalyzReport.self], inMemory: false)
        .environment(AppStore())
        .frame(width: 720, height: 480)
}
