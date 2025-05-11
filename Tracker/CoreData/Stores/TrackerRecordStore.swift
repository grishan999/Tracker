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
    
    func addRecord(trackerId: UUID, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date
        try context.save()
    }
    
    func deleteRecord(trackerId: UUID, date: Date) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)
        
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        let records = try context.fetch(request)
        if let record = records.first {
            context.delete(record)
            try context.save()
        }
    }
    
    func fetchRecords(for trackerId: UUID, on date: Date? = nil) -> [TrackerRecord] {
        guard let records = fetchedResultsController?.fetchedObjects else { return [] }
        
        return records.compactMap {
            guard let id = $0.trackerId, let recordDate = $0.date else { return nil }
            if let date = date {
                return Calendar.current.isDate(recordDate, inSameDayAs: date) ?
                TrackerRecord(trackerId: id, date: recordDate) : nil
            }
            return TrackerRecord(trackerId: id, date: recordDate)
        }.filter { $0.trackerId == trackerId }
    }
    
    func fetchCompletedTrackerIDs(for date: Date) -> [UUID] {
        guard let records = fetchedResultsController?.fetchedObjects else { return [] }
        let calendar = Calendar.current
        return records.compactMap {
            guard let id = $0.trackerId, let recordDate = $0.date,
                  calendar.isDate(recordDate, inSameDayAs: date) else { return nil }
            return id
        }
    }
    
    func isTrackerCompletedToday(id: UUID, date: Date) -> Bool {
        guard let recordsCoreData = fetchedResultsController?.fetchedObjects else {
            return false
        }
        
        let calendar = Calendar.current
        return recordsCoreData.contains { coreData in
            guard let coreDataTrackerId = coreData.trackerId,
                  let recordDate = coreData.date else {
                return false
            }
            return coreDataTrackerId == id && calendar.isDate(recordDate, inSameDayAs: date)
        }
    }
    
    func completedDaysCount(for trackerId: UUID) -> Int {
        guard let recordsCoreData = fetchedResultsController?.fetchedObjects else {
            return 0
        }
        
        return recordsCoreData.filter { $0.trackerId == trackerId }.count
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
}
