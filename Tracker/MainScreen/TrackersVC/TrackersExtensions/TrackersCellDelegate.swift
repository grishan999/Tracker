//
//  TrackersCellDelegate.swift
//  Tracker
//
//  Created by Ilya Grishanov on 02.05.2025.
//
import UIKit

extension TrackersViewController: TrackersCellDelegate {
    func didToggleCompletion(for trackerID: UUID, on date: Date, isCompleted: Bool) {
        if isCompleted {
            let records = trackerRecordStore.fetchRecords(for: trackerID)
            let alreadyCompleted = records.contains { record in
                Calendar.current.isDate(record.date, inSameDayAs: date)
            }
            
            if !alreadyCompleted {
                try? trackerRecordStore.addRecord(trackerId: trackerID, date: date)
            }
        } else {
            try? trackerRecordStore.deleteRecord(trackerId: trackerID, date: date)
        }
        
        DispatchQueue.main.async {
            self.filterTrackers(for: self.currentDate)
            self.trackersCollectionView.reloadData()
        }
    }
    
    func canCompleteTracker(id: UUID, on date: Date) -> Bool {
        return true
    }
    
}
