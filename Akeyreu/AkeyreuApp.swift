//
//  AkeyreuApp.swift
//  Akeyreu
//
//  Created by Kayvan Fouladinovid on 10/29/23.
//

import SwiftUI

@main
struct AkeyreuApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
//            DeviceDiscoveryView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
