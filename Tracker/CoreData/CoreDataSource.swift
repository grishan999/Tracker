//
//  CoreDataSource.swift
//  Tracker
//
//  Created by Ilya Grishanov on 15.04.2025.
//

import CoreData

final class CoreDataSource {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Library")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
