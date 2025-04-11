//
//  DWMApp.swift
//  DWM
//
//  Created by Ethan  Nguyen on 4/11/25.
//

import SwiftUI

@main
struct DWMApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
