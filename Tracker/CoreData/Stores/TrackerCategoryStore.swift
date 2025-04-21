//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Ilya Grishanov on 18.04.2025.
//

import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
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
           // Принудительно обновляем перед получением данных
           try? fetchedResultsController.performFetch()
           
           guard let categoriesCoreData = fetchedResultsController.fetchedObjects else {
               print("Нет данных в fetchedResultsController")
               return []
           }
           
           print("Найдено категорий в Core Data: \(categoriesCoreData.count)")
           
           let result = categoriesCoreData.compactMap { coreData -> TrackerCategory? in
               guard let title = coreData.title else {
                   print("Категория без названия")
                   return nil
               }
               
               let trackers = (coreData.trackers?.allObjects as? [TrackerCoreData])?
                   .compactMap { Tracker(from: $0) } ?? []
               
               print("Категория: \(title), трекеров: \(trackers.count)")
               return TrackerCategory(title: title, trackers: trackers)
           }
           
           print("Итоговые категории: \(result.map { $0.title })")
           return result
       }
    
    func ensureCleaningCategoryExists() throws {
           let request = TrackerCategoryCoreData.fetchRequest()
           request.predicate = NSPredicate(format: "title == %@", "Уборка")
           
           if try context.count(for: request) == 0 {
               let category = TrackerCategoryCoreData(context: context)
               category.title = "Уборка"
               try context.save()
               
               // Принудительно обновляем fetchedResultsController
               try fetchedResultsController.performFetch()
               print("Категория 'Уборка' создана и fetchedResultsController обновлен")
           }
       }
  }
