//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Ilya Grishanov on 18.04.2025.
//

import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext = CoreDataSource.shared.context) {
        self.context = context
        super.init()
        
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = delegate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func addCategory(title: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        guard let categoriesCoreData = fetchedResultsController.fetchedObjects else { return [] }
        
        return categoriesCoreData.compactMap { coreData -> TrackerCategory? in
            guard let title = coreData.title else { return nil }
            
            let trackers = (coreData.trackers?.allObjects as? [TrackerCoreData])?
                .compactMap { Tracker(from: $0) } ?? []
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
}
