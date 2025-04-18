//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Ilya Grishanov on 18.04.2025.
//
import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    weak var delegate: NSFetchedResultsControllerDelegate?
    
    init(context: NSManagedObjectContext = CoreDataSource.shared.context) {
        self.context = context
        super.init()
        
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
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
    
    func addRecord(trackerId: UUID, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date
        try context.save()
    }
    
    func fetchRecords() -> [TrackerRecord] {
        guard let recordsCoreData = fetchedResultsController.fetchedObjects else { return [] }
        
        return recordsCoreData.compactMap { coreData in
            guard let trackerId = coreData.trackerId,
                  let date = coreData.date else {
                return nil
            }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
}
