//
//  DeleteTrackerExtension.swift
//  Tracker
//
//  Created by Ilya Grishanov on 01.05.2025.
//
import UIKit

extension TrackersViewController {
    func showDeleteAlert(for tracker: Tracker, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: "Удалить",
            style: .destructive
        ) { [weak self] _ in
            self?.performDeleteTracker(tracker, at: indexPath)
        }
        
        let cancelAction = UIAlertAction(
            title: "Отменить",
            style: .cancel
        )
    
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func performDeleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        do {
            try trackerStore.deleteTracker(with: tracker.id)
        
            categories[indexPath.section].trackers.remove(at: indexPath.row)
            
            if categories[indexPath.section].trackers.isEmpty {
                categories.remove(at: indexPath.section)
                trackersCollectionView.deleteSections(IndexSet(integer: indexPath.section))
            } else {
                trackersCollectionView.deleteItems(at: [indexPath])
            }
            
            updatePlaceholderVisibility()
            
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }
    }
}
