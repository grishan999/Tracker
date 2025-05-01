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
    
    init(context: NSManagedObjectContext = CoreDataSource.shared.context) {
        self.context = context
        super.init()
    }
    
    func addTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        guard let category = try? context.fetch(request).first else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Категория '\(categoryTitle)' не найдена"])
        }
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.schedule = convertScheduleToCoreData(schedule: Array(tracker.schedule))
        trackerCoreData.category = category
        
        try? context.save()
    }
    
    func fetchTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        guard let trackersCoreData = try? context.fetch(request) else {
            return []
        }
        
        return trackersCoreData.compactMap { coreData -> Tracker? in
            guard let id = coreData.id,
                  let title = coreData.title,
                  let emoji = coreData.emoji,
                  let colorHex = coreData.color else {
                return nil
            }
            
            guard let color = UIColor(hex: colorHex) else {
                print("Failed to create color from hex: \(colorHex)")
                return nil
            }
            
            guard let category = coreData.category,
                  let categoryTitle = category.title else {
                print("Category or category title is missing")
                return nil
            }
            
            let schedule = convertCoreDataToSchedule(stringSchedule: coreData.schedule ?? "")
            
            return Tracker(
                id: id,
                title: title,
                color: color,
                emoji: emoji,
                schedule: Set(schedule),
                category: TrackerCategory(title: categoryTitle, trackers: []),
                isPinned: coreData.isPinned
            )
        }
    }
    
    func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let existingCategory = try? context.fetch(request).first {
            return existingCategory
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        try? context.save()
        return newCategory
    }
    
    func convertCoreDataToSchedule(stringSchedule: String) -> [Day] {
        guard !stringSchedule.isEmpty else { return [] }
        
        return stringSchedule
            .components(separatedBy: ",")
            .compactMap { Int($0) }
            .compactMap { Day(rawValue: $0) }
    }
    
    func convertScheduleToCoreData(schedule: [Day]) -> String {
        schedule.map { String($0.rawValue) }.joined(separator: ",")
    }
    
    func togglePin(for trackerID: UUID) throws {
            let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
            request.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
            
            let results = try context.fetch(request)
            guard let trackerToUpdate = results.first else { return }
            
            trackerToUpdate.isPinned = !trackerToUpdate.isPinned
            try context.save()
        }
}
