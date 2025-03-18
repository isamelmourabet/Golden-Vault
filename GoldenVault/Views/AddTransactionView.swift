import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionsViewModel
    
    let initialTransactionType: Transaction.TransactionType
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var category: Transaction.Category = .otros
    @State private var date = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @State private var type: Transaction.TransactionType
    
    init(viewModel: TransactionsViewModel, type: Transaction.TransactionType) {
        self.viewModel = viewModel
        self.initialTransactionType = type
        _type = State(initialValue: type)
    }
    
    var formattedAmount: String {
        if let value = Double(amount) {
            return String(format: "$ %.2f", value)
        }
        return "$ 0.00"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    // Tipo de Transacción
                    Picker("Tipo", selection: $type) {
                        Text("Gasto").tag(Transaction.TransactionType.expense)
                        Text("Ingreso").tag(Transaction.TransactionType.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Monto
                    Section {
                        HStack {
                            Text("Monto")
                            Spacer()
                            Text(formattedAmount)
                                .font(.title2)
                                .foregroundColor(type == .expense ? .red : .green)
                        }
                    }
                    
                    // Descripción
                    Section(header: Text("Descripción")) {
                        TextField("Descripción", text: $description)
                    }
                    
                    // Categoría
                    Section(header: Text("Categoría")) {
                        Picker("Categoría", selection: $category) {
                            ForEach(Transaction.Category.allCases, id: \.self) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }.tag(category)
                            }
                        }
                    }
                    
                    // Fecha
                    Section(header: Text("Fecha")) {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }
                
                Divider()
                
                // Teclado numérico personalizado
                CustomNumericKeypad(amount: $amount)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Nueva Transacción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if validateTransaction() {
                            saveTransaction()
                        }
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func validateTransaction() -> Bool {
        guard let amountValue = Double(amount) else {
            alertMessage = "Por favor, ingrese un monto válido"
            showingAlert = true
            return false
        }
        
        if amountValue <= 0 {
            alertMessage = "El monto debe ser mayor que cero"
            showingAlert = true
            return false
        }
        
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Por favor, ingrese una descripción"
            showingAlert = true
            return false
        }
        
        return true
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let transaction = Transaction(
            amount: amountValue,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            type: type,
            date: date
        )
        
        viewModel.addTransaction(transaction)
        dismiss()
    }
} 