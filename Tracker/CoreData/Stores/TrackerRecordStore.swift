//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Ilya Grishanov on 18.04.2025.
//
import CoreData

final class TrackerRecordStore: NSObject {
    private(set) var context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedResultsController?.delegate = delegate
        }
    }
    
    init(context: NSManagedObjectContext = CoreDataSource.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = delegate
        try? controller.performFetch()
        self.fetchedResultsController = controller
    }
    
    func addRecord(trackerId: UUID, date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date
        try? context.save()
    }
    
    func fetchRecords(for trackerId: UUID) -> [TrackerRecord] {
        guard let recordsCoreData = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        return recordsCoreData.compactMap { coreData in
            guard let coreDataTrackerId = coreData.trackerId,
                  let date = coreData.date,
                  coreDataTrackerId == trackerId else {
                return nil
            }
            
            return TrackerRecord(trackerId: coreDataTrackerId, date: date)
        }
    }
}

