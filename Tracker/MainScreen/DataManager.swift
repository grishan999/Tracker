//
//  DataManager.swift
//  Tracker
//
//  Created by Ilya Grishanov on 06.04.2025.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    var categories: [TrackerCategory] = [
         TrackerCategory(
             title: "Уборка",
             trackers: [
                 Tracker(
                     id: UUID(),
                     title: "Убраться в комнате",
                     color: "CustomBlue",
                     emoji: "🧹",
                     schedule: [.Friday,.Sunday]
                 ),
                 Tracker(
                    id: UUID(),
                    title: "Помыть посуду",
                    color: "CustomGreen",
                    emoji: "🧽",
                    schedule: [.Monday,.Wednesday,.Friday]
                 )
             ]
         ),
         TrackerCategory(
            title: "Домашнее задание",
            trackers: [
                Tracker (id: UUID(),
                         title: "Сделать домашнее задание",
                         color: "CustomRed",
                         emoji: "📚",
                         schedule: [.Monday,.Tuesday,.Thursday,.Saturday]),
                Tracker (id: UUID(),
                         title: "Закончить 14 спринт",
                         color: "CustomOrange",
                         emoji: "👨🏻‍💻",
                         schedule: [.Monday,.Tuesday,.Thursday,.Saturday])
                      ]
         )
     ]
    
    private lazy var categoriesSource: [TrackerCategory] = [TrackerCategory(title: "Уборка", trackers: []),
                                                            TrackerCategory(title: "Домашнее задание", trackers: [])]
    
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
        if let index = categories.firstIndex(where: { $0.title == title }) {
            categories[index].trackers.append(tracker)
        } else {
            let newCategory = TrackerCategory(title: title, trackers: [tracker])
            categories.append(newCategory)
        }
    
        print("Добавлен трекер: \(tracker.title) в категорию: \(title)")
        print("Текущие категории: \(categories)")
    }
    
    func addCategory(_ category: TrackerCategory) {
        categoriesSource.append(category)
    }
    
    
 }
