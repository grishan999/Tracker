//
//  TrackerStore.swift
//  Tracker
//
//  Created by Ilya Grishanov on 18.04.2025.
//
import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext = CoreDataSource.shared.context) {
        self.context = context
        super.init()
        
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request = TrackerCoreData.fetchRequest()
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
    
    func addTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let category = try fetchOrCreateCategory(with: categoryTitle)
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = try NSKeyedArchiver.archivedData(
            withRootObject: tracker.color,
            requiringSecureCoding: false
        )
        trackerCoreData.schedule = Array(tracker.schedule) as NSObject 
        trackerCoreData.category = category
        
        try context.save()
    }
    
    func fetchTrackers() -> [Tracker] {
        guard let trackersCoreData = fetchedResultsController.fetchedObjects else { return [] }
        
        var trackers: [Tracker] = []
        for coreData in trackersCoreData {
            if let tracker = Tracker(from: coreData) {
                trackers.append(tracker)
            }
        }
        return trackers
    }
    
    private func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let existingCategory = try? context.fetch(request).first {
            return existingCategory
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        return newCategory
    }
}
