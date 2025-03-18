import SwiftUI

struct TransactionFilters: View {
    @Binding var searchText: String
    @Binding var selectedType: TransactionTypeFilter
    @Binding var selectedCategory: Transaction.Category?
    @Binding var selectedDateRange: DateRange
    
    @State private var animateGradient: Bool = false
    
    enum TransactionTypeFilter {
        case all
        case expenses
        case income
    }
    
    enum DateRange: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case year = "Año"
        case all = "Todo"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Barra de búsqueda
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Buscar transacción", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Filtro de tipo de transacción
            Picker("Tipo", selection: $selectedType) {
                Text("Todos").tag(TransactionTypeFilter.all)
                Text("Gastos").tag(TransactionTypeFilter.expenses)
                Text("Ingresos").tag(TransactionTypeFilter.income)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Filtro de categorías
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryFilterButton(
                        category: nil,
                        selectedCategory: $selectedCategory,
                        label: "Todas"
                    )
                    
                    ForEach(Transaction.Category.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            category: category,
                            selectedCategory: $selectedCategory,
                            label: category.rawValue
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Filtro de rango de fechas
            Picker("Período", selection: $selectedDateRange) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background {
            LinearGradient(colors: [Color("lightrose"),Color("lightblue")/*, Color(.white)*/],
                          startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .hueRotation(.degrees(animateGradient ? 120 : 0))
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
        }
    }
}

struct CategoryFilterButton: View {
    let category: Transaction.Category?
    @Binding var selectedCategory: Transaction.Category?
    let label: String
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedCategory = category
            }
        }) {
            Text(label)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
    
    private var isSelected: Bool {
        selectedCategory == category
    }
}
