//
//  AssessmentAppApp.swift
//  AssessmentApp
//
//  Created by Jenil Jariwala on 2024-03-01.
//

import SwiftUI

@main
struct YourApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

