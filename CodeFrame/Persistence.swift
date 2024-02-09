//
//  Persistence.swift
//  CodeFrame
//
//  Created by 施家浩 on 2024/2/9.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let item = Item(context: viewContext)
        item.title = "dummy"
        item.textCode = "1234-abcd"
        item.favorite = false
        item.showAsQRcode = false
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "CodeFrame")
        // Setup for share coreData with widget extension
        #if DEBUG
        let url = URL.storeURL(for: "group.com.vocaltale.app.CodeFrame.deBug", databaseName: "CodeFrame")
        #else
        let url = URL.storeURL(for: "group.com.vocaltale.app.CodeFrame", databaseName: "CodeFrame")
        #endif
        let storeDescription = NSPersistentStoreDescription(url: url)
        container.persistentStoreDescriptions = [storeDescription]
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Failed to create URL for \(appGroup)")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
