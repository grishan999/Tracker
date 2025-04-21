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
           // 1. Сначала убедимся, что категория "Уборка" существует
           let categoryStore = TrackerCategoryStore(context: context)
           try categoryStore.ensureCleaningCategoryExists()
           
           // 2. Получаем категорию "Уборка"
           let request = TrackerCategoryCoreData.fetchRequest()
           request.predicate = NSPredicate(format: "title == %@", "Уборка")
           guard let category = try context.fetch(request).first else {
               throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Категория 'Уборка' не найдена"])
           }
           
           // 3. Создаем трекер
           let trackerCoreData = TrackerCoreData(context: context)
           trackerCoreData.id = tracker.id
           trackerCoreData.title = tracker.title
           trackerCoreData.emoji = tracker.emoji
           trackerCoreData.color = colorToHexString(color: tracker.color)
           trackerCoreData.schedule = convertScheduleToCoreData(schedule: Array(tracker.schedule))
           trackerCoreData.category = category
           
           try context.save()
           print("Трекер успешно добавлен в категорию 'Уборка'")
       }
    
    
    func fetchTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let trackersCoreData = try context.fetch(request)
            return trackersCoreData.compactMap { coreData in
                guard let id = coreData.id,
                      let title = coreData.title,
                      let emoji = coreData.emoji,
                      let colorHex = coreData.color,
                      let color = hexStringToColor(hex: colorHex),
                      let category = coreData.category,
                      let categoryTitle = category.title else {
                    print("Invalid tracker data in CoreData")
                    return nil
                }
                
                let schedule = convertCoreDataToSchedule(stringSchedule: coreData.schedule ?? "")
                
                return Tracker(
                    id: id,
                    title: title,
                    color: color,
                    emoji: emoji,
                    schedule: Set(schedule),
                    category: TrackerCategory(title: categoryTitle, trackers: [])
                )
            }
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    
    private func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let existingCategory = try context.fetch(request).first {
            return existingCategory
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        try context.save()
        return newCategory
    }
    
    // Методы преобразования
    func convertCoreDataToSchedule(stringSchedule: String) -> [Day] {
        guard !stringSchedule.isEmpty else { return [] }
        return stringSchedule.components(separatedBy: ",")
            .compactMap { Int($0) }
            .compactMap { Day(rawValue: $0) }
    }
    
    func convertScheduleToCoreData(schedule: [Day]) -> String {
        return schedule.map { String($0.rawValue) }.joined(separator: ",")
    }
    
    
    
    private func colorToHexString(color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
    
    private func hexStringToColor(hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
