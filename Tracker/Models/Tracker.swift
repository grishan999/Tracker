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
    let category: TrackerCategory
    
    init(id: UUID, title: String, color: UIColor, emoji: String, schedule: Set<Day>, category: TrackerCategory) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.category = category
    }
    
    init?(from coreData: TrackerCoreData) {
        guard
            let id = coreData.id,
            let title = coreData.title,
            let emoji = coreData.emoji,
            let schedule = coreData.schedule,
            let color = coreData.color,
            let categoryCoreData = coreData.category
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.emoji = emoji
        self.color = UIColor(hex: color) ?? .systemBlue
        self.schedule = Set(schedule.components(separatedBy: ",").compactMap {
            guard let rawValue = Int($0) else { return nil }
            return Day(rawValue: rawValue)
        })
        self.category = TrackerCategory(
            title: categoryCoreData.title ?? "",
            trackers: []
        )
    }
}

// Расширение для UIColor для работы с HEX
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
