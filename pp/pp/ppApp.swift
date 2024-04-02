//
//  ppApp.swift
//  pp
//
//  Created by 김지현 on 2024/04/02.
//

import SwiftUI

@main
struct ppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
