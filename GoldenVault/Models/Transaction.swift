import Foundation

struct Transaction: Identifiable, Codable {
    var id: UUID
    var amount: Double
    var description: String
    var category: Category
    var type: TransactionType
    var date: Date
    
    init(id: UUID = UUID(), amount: Double, description: String, category: Category, type: TransactionType, date: Date) {
        self.id = id
        self.amount = amount
        self.description = description
        self.category = category
        self.type = type
        self.date = date
    }
    
    enum TransactionType: String, Codable {
        case expense
        case income
    }
    
    enum Category: String, Codable, CaseIterable {
        case comida = "Comida"
        case transporte = "Transporte"
        case entretenimiento = "Entretenimiento"
        case servicios = "Servicios"
        case compras = "Compras"
        case otros = "Otros"
        
        var icon: String {
            switch self {
            case .comida: return "fork.knife"
            case .transporte: return "car.fill"
            case .entretenimiento: return "tv.fill"
            case .servicios: return "bolt.fill"
            case .compras: return "cart.fill"
            case .otros: return "square.fill"
            }
        }
    }
}

extension Transaction {
    static func from(_ entity: TransactionEntity) -> Transaction? {
        guard let id = entity.id,
              let description = entity.descriptionText,
              let categoryStr = entity.category,
              let typeStr = entity.type,
              let category = Category(rawValue: categoryStr),
              let type = TransactionType(rawValue: typeStr) else {
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
} 