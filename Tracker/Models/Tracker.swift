//
//  Tracker.swift
//  Tracker
//
//  Created by Ilya Grishanov on 02.04.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Day>
    
    // Обычный инициализатор
    init(id: UUID, title: String, color: UIColor, emoji: String, schedule: Set<Day>) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
    
    // Инициализатор из CoreData
    init?(from coreData: TrackerCoreData) {
        guard
            let id = coreData.id,
            let title = coreData.title,
            let emoji = coreData.emoji,
            let scheduleData = coreData.schedule as? Set<Day>
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.emoji = emoji
        self.schedule = scheduleData
        
        if let colorData = coreData.color {
            self.color = (try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)) ?? UIColor()
        } else {
            self.color = UIColor()
        }
    }
}
