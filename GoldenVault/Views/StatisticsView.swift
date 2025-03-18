import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @State private var selectedPeriod: TimePeriod = .month
    
    enum TimePeriod: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case year = "Año"
    }
    
    var body: some View {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        Group {
            if isIPad {
                mainContent
            } else {
                NavigationView {
                    mainContent
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Selector de período
                Picker("Período", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Gráfico de gastos por categoría
                CategoryPieChart(viewModel: viewModel, period: selectedPeriod)
                    .frame(height: 300)
                    .padding()
                
                // Gráfico de tendencia
                TrendLineChart(viewModel: viewModel, period: selectedPeriod)
                    .frame(height: 200)
                    .padding()
                
                // Resumen por categorías
                CategorySummaryList(viewModel: viewModel, period: selectedPeriod)
                    .padding()
            }
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 800 : nil)
            .padding(.horizontal)
        }
        .navigationTitle("Estadísticas")
    }
}

struct CategoryPieChart: View {
    let viewModel: TransactionsViewModel
    let period: StatisticsView.TimePeriod
    
    var filteredData: [(category: Transaction.Category, amount: Double)] {
        let filtered = viewModel.transactions
            .filter { transaction in
                transaction.type == .expense &&
                isInSelectedPeriod(date: transaction.date, period: period)
            }
        
        return Transaction.Category.allCases.map { category in
            let amount = filtered
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }
            return (category, amount)
        }
        .filter { $0.amount > 0 }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gastos por Categoría")
                .font(.headline)
            
            Chart {
                ForEach(filteredData, id: \.category) { item in
                    SectorMark(
                        angle: .value("Monto", item.amount),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Categoría", item.category.rawValue))
                }
            }
        }
    }
}

struct TrendLineChart: View {
    let viewModel: TransactionsViewModel
    let period: StatisticsView.TimePeriod
    
    var groupedData: [(date: Date, expenses: Double, income: Double)] {
        let calendar = Calendar.current
        let now = Date()
        var dateComponents: DateComponents
        
        switch period {
        case .week:
            dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        case .month:
            dateComponents = calendar.dateComponents([.year, .month], from: now)
        case .year:
            dateComponents = calendar.dateComponents([.year], from: now)
        }
        
        guard let startDate = calendar.date(from: dateComponents) else { return [] }
        
        let filteredTransactions = viewModel.transactions.filter { $0.date >= startDate }
        var result: [(Date, Double, Double)] = []
        
        let groupedByDate = Dictionary(grouping: filteredTransactions) { transaction in
            let components: Set<Calendar.Component>
            switch period {
            case .week:
                components = [.year, .month, .day]
            case .month:
                components = [.year, .month, .day]
            case .year:
                components = [.year, .month]
            }
            return calendar.date(from: calendar.dateComponents(components, from: transaction.date)) ?? transaction.date
        }
        
        let sortedDates = groupedByDate.keys.sorted()
        
        for date in sortedDates {
            let transactions = groupedByDate[date] ?? []
            let expenses = transactions
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }
            let income = transactions
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amount }
            result.append((date, expenses, income))
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tendencia")
                .font(.headline)
            
            Chart {
                ForEach(groupedData, id: \.date) { item in
                    LineMark(
                        x: .value("Fecha", item.date),
                        y: .value("Gastos", item.expenses)
                    )
                    .foregroundStyle(.red)
                    .interpolationMethod(.monotone)
                    .symbol(Circle())
                    .symbolSize(30)
                    
                    AreaMark(
                        x: .value("Fecha", item.date),
                        y: .value("Gastos", item.expenses)
                    )
                    .foregroundStyle(.red.opacity(0.1))
                    .interpolationMethod(.monotone)
                    
                    LineMark(
                        x: .value("Fecha", item.date),
                        y: .value("Ingresos", item.income)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.monotone)
                    .symbol(Circle())
                    .symbolSize(30)
                    
                    AreaMark(
                        x: .value("Fecha", item.date),
                        y: .value("Ingresos", item.income)
                    )
                    .foregroundStyle(.green.opacity(0.1))
                    .interpolationMethod(.monotone)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(formatDate(date))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(String(format: "%.0f", amount))
                        }
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch period {
        case .week:
            formatter.dateFormat = "EEE"
        case .month:
            formatter.dateFormat = "d"
        case .year:
            formatter.dateFormat = "MMM"
        }
        return formatter.string(from: date)
    }
}

struct CategorySummaryList: View {
    let viewModel: TransactionsViewModel
    let period: StatisticsView.TimePeriod
    
    var categorySummary: [(category: Transaction.Category, amount: Double, percentage: Double)] {
        let totalExpenses = viewModel.transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        return filteredData.map { (category, amount) in
            let percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0
            return (category, amount, percentage)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Resumen por Categorías")
                .font(.headline)
            
            ForEach(categorySummary, id: \.category) { item in
                HStack {
                    Image(systemName: item.category.icon)
                        .foregroundColor(.blue)
                    Text(item.category.rawValue)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(String(format: "$%.2f", item.amount))
                        Text(String(format: "%.1f%%", item.percentage))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var filteredData: [(Transaction.Category, Double)] {
        let filtered = viewModel.transactions
            .filter { transaction in
                transaction.type == .expense &&
                isInSelectedPeriod(date: transaction.date, period: period)
            }
        
        return Transaction.Category.allCases.map { category in
            let amount = filtered
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }
            return (category, amount)
        }
        .filter { $0.1 > 0 }
    }
}

// Función auxiliar para filtrar por período
func isInSelectedPeriod(date: Date, period: StatisticsView.TimePeriod) -> Bool {
    let calendar = Calendar.current
    let now = Date()
    
    switch period {
    case .week:
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        return date >= weekStart
    case .month:
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        return date >= monthStart
    case .year:
        let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
        return date >= yearStart
    }
} 