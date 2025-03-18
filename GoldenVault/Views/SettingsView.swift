import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("currency") private var currency = "€"
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    let currencies = ["€", "$", "£", "¥"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Apariencia")) {
                    Toggle("Modo Oscuro", isOn: $isDarkMode)
                }
                
                Section(header: Text("Preferencias")) {
                    Picker("Moneda", selection: $currency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                }
                
                Section(header: Text("Notificaciones")) {
                    Toggle("Activar Notificaciones", isOn: $notificationsEnabled)
                }
                
                Section(header: Text("Datos")) {
                    Button("Exportar Datos") {
                        // TODO: Implementar exportación
                    }
                    
                    Button("Borrar Todos los Datos", role: .destructive) {
                        // TODO: Implementar borrado
                    }
                }
                
                Section(header: Text("Acerca de")) {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : nil)
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
} 