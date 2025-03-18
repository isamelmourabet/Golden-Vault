import SwiftUI

struct TransactionsView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @State private var showingAddTransactionBuy = false
    @State private var showingAddTransactionSell = false

    @State private var transactionType: Transaction.TransactionType = .expense
    @State private var showFilters = false
    @State private var showSettings = false
    @State private var animateGradient: Bool = false
    
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
        .sheet(isPresented: $showingAddTransactionSell) {
            AddTransactionView(viewModel: viewModel, type: .expense)
        }
        .sheet(isPresented: $showingAddTransactionBuy) {
            AddTransactionView(viewModel: viewModel, type: .income)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            if showFilters {
                TransactionFilters(
                    searchText: $viewModel.searchText,
                    selectedType: $viewModel.selectedType,
                    selectedCategory: $viewModel.selectedCategory,
                    selectedDateRange: $viewModel.selectedDateRange
                )
                .background(
                    LinearGradient(colors: [Color("lightrose"),Color("lightblue"), Color(.white)],
                                  startPoint: .topLeading,
                                  endPoint: .center)
                        .opacity(0.5)
                )
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Card
                    balanceCard
                    
                    // Action Buttons
                    actionButtons
                    
                    // Transactions List
                    transactionsList
                }
                .padding()
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 800 : nil)
            }
        }
        .navigationTitle("Mi Presupuesto")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showFilters.toggle() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(showFilters ? .primary : .blue)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                }
            }
        }
        .background {
            LinearGradient(colors: [Color("lightrose"),Color("lightblue"), Color(.white)],
                          startPoint: .topLeading,
                          endPoint: .center)
                .ignoresSafeArea()
                .hueRotation(.degrees(animateGradient ? 120 : 0))
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
        }
    }
    
    private var balanceCard: some View {
        VStack {
            Text("Balance Total")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(String(format: "$%.2f", viewModel.balance))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemFill))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 20) {
            ActionButton(
                icon: "minus.circle.fill",
                title: "Gasto",
                color: .red
            ) {
                showingAddTransactionSell = true
            }
            
            ActionButton(
                icon: "plus.circle.fill",
                title: "Ingreso",
                color: .green
            ) {
                showingAddTransactionBuy = true
            }
        }
    }
    
    private var transactionsList: some View {
        List {
            ForEach(viewModel.filteredTransactions) { transaction in
                TransactionRow(transaction: transaction)
                    .listRowBackground(Color(.systemFill))
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
//        .scrollContentBackground(.hidden)
        .frame(minHeight: 370/*, maxHeight: .infinity*/)
        .cornerRadius(20)
    }
} 
