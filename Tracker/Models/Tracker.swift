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
    
    enum CodingKeys: String, CodingKey {
        case id, title, color, emoji, schedule
    }
}

