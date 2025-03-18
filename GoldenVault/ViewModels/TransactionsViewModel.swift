import CoreData
import SwiftUI

class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var balance: Double = 0.0
    
    @Published var searchText = ""
    @Published var selectedType: TransactionFilters.TransactionTypeFilter = .all
    @Published var selectedCategory: Transaction.Category?
    @Published var selectedDateRange: TransactionFilters.DateRange = .month
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchTransactions()
    }
    
    func fetchTransactions() {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            let entities = try viewContext.fetch(request)
            transactions = entities.compactMap { entity in
                guard let id = entity.id,
                      let description = entity.descriptionText,
                      let categoryStr = entity.category,
                      let typeStr = entity.type,
                      let category = Transaction.Category(rawValue: categoryStr),
                      let type = Transaction.TransactionType(rawValue: typeStr) else {
                    return nil
                }
                
                return Transaction(
                    id: id,
                    amount: entity.amount,
                    description: description,
                    category: category,
                    type: type,
                    date: entity.date ?? Date()
                )
            }
            calculateBalance()
        } catch {
            print("Error al cargar transacciones: \(error)")
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        let entity = TransactionEntity(context: viewContext)
        entity.id = transaction.id
        entity.amount = transaction.amount
        entity.descriptionText = transaction.description
        entity.category = transaction.category.rawValue
        entity.type = transaction.type.rawValue
        entity.date = transaction.date
        
        do {
            try viewContext.save()
            fetchTransactions()
        } catch {
            print("Error al guardar transacción: \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        
        do {
            let entities = try viewContext.fetch(request)
            if let entity = entities.first {
                viewContext.delete(entity)
                try viewContext.save()
                fetchTransactions()
            }
        } catch {
            print("Error al eliminar transacción: \(error)")
        }
    }
    
    func calculateBalance() {
        balance = transactions.reduce(0) { result, transaction in
            switch transaction.type {
            case .income:
                return result + transaction.amount
            case .expense:
                return result - transaction.amount
            }
        }
    }
    
    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            // Filtro de búsqueda
            let matchesSearch = searchText.isEmpty ||
                transaction.description.localizedCaseInsensitiveContains(searchText)
            
            // Filtro de tipo
            let matchesType: Bool
            switch selectedType {
            case .all:
                matchesType = true
            case .expenses:
                matchesType = transaction.type == .expense
            case .income:
                matchesType = transaction.type == .income
            }
            
            // Filtro de categoría
            let matchesCategory = selectedCategory == nil || transaction.category == selectedCategory
            
            // Filtro de fecha
            let matchesDate = isInSelectedDateRange(date: transaction.date)
            
            return matchesSearch && matchesType && matchesCategory && matchesDate
        }
    }
    
    private func isInSelectedDateRange(date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedDateRange {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return date >= weekStart
        case .month:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return date >= monthStart
        case .year:
            let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return date >= yearStart
        case .all:
            return true
        }
    }
}

extension TransactionsViewModel {
    enum DataError: Error {
        case fetchError
        case saveError
        case deleteError
        
        var localizedDescription: String {
            switch self {
            case .fetchError:
                return "Error al cargar las transacciones"
            case .saveError:
                return "Error al guardar la transacción"
            case .deleteError:
                return "Error al eliminar la transacción"
            }
        }
    }
    
    private func handleError(_ error: Error, type: DataError) {
        print("\(type.localizedDescription): \(error)")
        // Aquí podrías implementar una lógica para mostrar errores al usuario
    }
} 