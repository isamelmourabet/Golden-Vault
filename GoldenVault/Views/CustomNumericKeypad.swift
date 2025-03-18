import SwiftUI

struct CustomNumericKeypad: View {
    @Binding var amount: String
    
    private let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { button in
                        KeypadButton(title: button) {
                            handleInput(button)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func handleInput(_ button: String) {
        switch button {
        case "⌫":
            if !amount.isEmpty {
                amount.removeLast()
            }
        case ".":
            if !amount.contains(".") && amount.count < 10 {
                amount += button
            }
        default:
            if isValidAmount(amount + button) {
                amount += button
            }
        }
    }
    
    private func isValidAmount(_ str: String) -> Bool {
        // Validar longitud máxima
        guard str.count <= 10 else { return false }
        
        // Validar formato decimal
        let components = str.components(separatedBy: ".")
        if components.count > 2 { return false }
        if components.count == 2 && components[1].count > 2 { return false }
        
        return true
    }
}

struct KeypadButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
} 