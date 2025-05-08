//
//  Day.swift
//  Tracker
//
//  Created by Ilya Grishanov on 02.04.2025.
//

import Foundation

enum Day: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    var localizedName: String {
           let key: String
           switch self {
           case .monday: key = "weekday.monday.full"
           case .tuesday: key = "weekday.tuesday.full"
           case .wednesday: key = "weekday.wednesday.full"
           case .thursday: key = "weekday.thursday.full"
           case .friday: key = "weekday.friday.full"
           case .saturday: key = "weekday.saturday.full"
           case .sunday: key = "weekday.sunday.full"
           }
           return NSLocalizedString(key, comment: "Полное название дня недели")
       }
       
       var shortName: String {
           let key: String
           switch self {
           case .monday: key = "weekday.monday.short"
           case .tuesday: key = "weekday.tuesday.short"
           case .wednesday: key = "weekday.wednesday.short"
           case .thursday: key = "weekday.thursday.short"
           case .friday: key = "weekday.friday.short"
           case .saturday: key = "weekday.saturday.short"
           case .sunday: key = "weekday.sunday.short"
           }
           return NSLocalizedString(key, comment: "Сокращенное название дня недели")
       }
    
    var calendarDayNumber: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}
