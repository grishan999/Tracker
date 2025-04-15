//
//  TrackerRecordCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Ilya Grishanov on 15.04.2025.
//
//

import Foundation
import CoreData


extension TrackerRecordCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }

    @NSManaged public var trackerId: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var tracker: TrackerCoreData?

}

extension TrackerRecordCoreData : Identifiable {

}
