//
//  CoreDataSource.swift
//  Tracker
//
//  Created by Ilya Grishanov on 16.04.2025.
//

import CoreData
import Foundation

final class CoreDataSource {
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Tracker")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    
                }
            })
            return container
        }()
    
}
