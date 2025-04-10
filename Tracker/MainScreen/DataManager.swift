//
//  DataManager.swift
//  Tracker
//
//  Created by Ilya Grishanov on 06.04.2025.
//

import Foundation

final class DataManager {
    static let shared = DataManager()

    private init() {}
    var categories: [TrackerCategory] = []

    private lazy var categoriesSource: [TrackerCategory] = [
        TrackerCategory(title: "Уборка", trackers: []),
        TrackerCategory(title: "Домашнее задание", trackers: []),
    ]

    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
        if let index = categories.firstIndex(where: { $0.title == title }) {
            categories[index].trackers.append(tracker)
        } else {
            let newCategory = TrackerCategory(title: title, trackers: [tracker])
            categories.append(newCategory)
        }
    }

    func addCategory(_ category: TrackerCategory) {
        categoriesSource.append(category)
    }

}
