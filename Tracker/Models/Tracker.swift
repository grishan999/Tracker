//
//  Tracker.swift
//  Tracker
//
//  Created by Ilya Grishanov on 02.04.2025.
//

import Foundation

struct Tracker {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: Set<Day>
    
    enum CodingKeys: String, CodingKey {
        case id, title, color, emoji, schedule
    }
}

