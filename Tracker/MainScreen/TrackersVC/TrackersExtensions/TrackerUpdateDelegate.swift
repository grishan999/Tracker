//
//  TrackerUpdateDelegate.swift
//  Tracker
//
//  Created by Ilya Grishanov on 02.05.2025.
//
import UIKit

extension TrackersViewController: TrackerUpdateDelegate {
    func didUpdateTracker(_ oldTracker: Tracker, with newTracker: Tracker) {
        do {
            try trackerStore.updateTracker(
                with: oldTracker.id,
                newTitle: newTracker.title,
                newEmoji: newTracker.emoji,
                newColor: newTracker.color,
                newSchedule: newTracker.schedule,
                newCategory: newTracker.category.title
            )
            
            categories = trackerCategoryStore.fetchCategories()
            filterTrackers(for: currentDate)
            trackersCollectionView.reloadData()
            
        } catch {
            print("Ошибка при обновлении трекера: \(error)")
        }
    }
}

