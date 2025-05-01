//
//  TrackersCellDelegate.swift
//  Tracker
//
//  Created by Ilya Grishanov on 02.05.2025.
//
import UIKit

extension TrackersViewController: TrackersCellDelegate {
    func didToggleCompletion(for trackerID: UUID, on date: Date, isCompleted: Bool) {
        guard Calendar.current.startOfDay(for: date) <= Calendar.current.startOfDay(for: Date()) else { return }
        
        do {
            if isCompleted {
                let records = trackerRecordStore.fetchRecords(for: trackerID)
                if !records.contains(where: {
                    Calendar.current.isDate($0.date, inSameDayAs: date)
                }) {
                    try trackerRecordStore.addRecord(trackerId: trackerID, date: date)
                }
            } else {
                let records = trackerRecordStore.fetchRecords(for: trackerID)
                if let recordToRemove = records.first(where: {
                    Calendar.current.isDate($0.date, inSameDayAs: date)
                }) {
                    guard let fetchedObjects = trackerRecordStore.fetchedResultsController?.fetchedObjects else { return }
                    
                    if let index = fetchedObjects.firstIndex(where: {
                        $0.trackerId == recordToRemove.trackerId &&
                        Calendar.current.isDate($0.date!, inSameDayAs: recordToRemove.date)
                    }) {
                        let object = trackerRecordStore.fetchedResultsController?.object(at: IndexPath(row: index, section: 0))
                        if let object = object {
                            trackerRecordStore.context.delete(object)
                            try trackerRecordStore.context.save()
                        }
                    }
                }
            }
            
            categories = trackerCategoryStore.fetchCategories()
            filterTrackers(for: currentDate)
            trackersCollectionView.reloadData()
        } catch {
            if let indexPath = findIndexPath(for: trackerID) {
                trackersCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    private func findIndexPath(for trackerID: UUID) -> IndexPath? {
        for (section, category) in categories.enumerated() {
            if let row = category.trackers.firstIndex(where: { $0.id == trackerID }) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }
}
