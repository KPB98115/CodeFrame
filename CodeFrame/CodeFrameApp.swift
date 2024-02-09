//
//  CodeFrameApp.swift
//  CodeFrame
//
//  Created by 施家浩 on 2024/2/9.
//

import SwiftUI

@main
struct CodeFrameApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
