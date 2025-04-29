//
//  TrackersCollection.swift
//  Tracker
//
//  Created by Ilya Grishanov on 29.04.2025.
//
import UIKit

extension TrackersViewController: UICollectionViewDataSource,
                                  UICollectionViewDelegate
{
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let nonEmptyCategories = categories.filter { !$0.trackers.isEmpty }
        return nonEmptyCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.filter { !$0.trackers.isEmpty }.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackersCell.cellIdentifier, for: indexPath
            ) as? TrackersCell
        else {
            fatalError("Unable to dequeue TrackersCell")
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let records = trackerRecordStore.fetchRecords(for: tracker.id)
        let isCompletedToday = records.contains { record in
            Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
        
        let uniqueDays = Set(records.map { Calendar.current.startOfDay(for: $0.date) }).count
        
        let today = Calendar.current.startOfDay(for: Date())
        let cellDate = Calendar.current.startOfDay(for: currentDate)
        let isEnabled = cellDate <= today
        
        cell.setupCell(
            name: tracker.title,
            color: tracker.color,
            emoji: Character(tracker.emoji),
            days: tracker.schedule.isEmpty ? (isCompletedToday ? 1 : 0) : uniqueDays,
            trackerID: tracker.id,
            isCompletedToday: isCompletedToday,
            isEnabled: isEnabled,
            currentDate: currentDate,
            isEvent: tracker.schedule.isEmpty
        )
        
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard
                let headerView =
                    collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: HeaderCategoryView
                            .headerIdentifier,
                        for: indexPath
                    ) as? HeaderCategoryView
            else {
                return UICollectionReusableView()
            }
            
            let nonEmptyCategories = categories.filter { !$0.trackers.isEmpty }
            headerView.titleLabel.text =
            nonEmptyCategories[indexPath.section].title
            return headerView
            
        default:
            fatalError("Unexpected supplementary view kind: \(kind)")
        }
    }
}

