//
//  ContentView.swift
//  GoldenVault
//
//  Created by Isam El Mourabet on 21/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TransactionsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Diseño específico para iPad
            NavigationSplitView(columnVisibility: .constant(.all)) {
                List {
                    Button {
                        selectedTab = 0
                    } label: {
                        Label("Transacciones", systemImage: "list.bullet")
                            .foregroundColor(selectedTab == 0 ? .blue : .primary)
                    }
                    
                    Button {
                        selectedTab = 1
                    } label: {
                        Label("Estadísticas", systemImage: "chart.pie")
                            .foregroundColor(selectedTab == 1 ? .blue : .primary)
                    }
                }
                .navigationTitle("GoldenVault")
            } detail: {
                switch selectedTab {
                case 0:
                    TransactionsView(viewModel: viewModel)
                case 1:
                    StatisticsView(viewModel: viewModel)
                default:
                    TransactionsView(viewModel: viewModel)
                }
            }
        } else {
            // Diseño para iPhone
            TabView(selection: $selectedTab) {
                TransactionsView(viewModel: viewModel)
                    .tabItem {
                        Label("Transacciones", systemImage: "list.bullet")
                    }
                    .tag(0)
                
                StatisticsView(viewModel: viewModel)
                    .tabItem {
                        Label("Estadísticas", systemImage: "chart.pie")
                    }
                    .tag(1)
            }
        }
    }
}

// Componentes auxiliares
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category.icon)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.headline)
                Text(transaction.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(String(format: "$%.2f", transaction.amount))
                .foregroundColor(transaction.type == .expense ? .red : .green)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        
    }
}

#Preview {
    ContentView()
}
