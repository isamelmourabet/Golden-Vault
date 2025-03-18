//
//  GoldenVaultApp.swift
//  GoldenVault
//
//  Created by Isam El Mourabet on 21/12/24.
//

import SwiftUI

@main
struct GoldenVaultApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
