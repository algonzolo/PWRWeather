//
//  Utils.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import Foundation

func isToday(_ weekDay: String) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    let today = dateFormatter.string(from: Date())
    return weekDay == today
}


func isNightTimeNow() -> Bool {
    let calendar = Calendar.current
    let now = Date()
    let currentHour = calendar.component(.hour, from: now)
    
    let nightStartHour = 19
    let nightEndHour = 7
    
    return currentHour >= nightStartHour || currentHour < nightEndHour
}

func degreeSymbolOffsetX(for temperature: Int) -> CGFloat {
    let temperatureString = String(temperature)
    let digitCount = temperatureString.count
    
    switch digitCount {
    case 1: // One digit
        return 40
    case 2: // Two digits
        return 70
    case 3: // Three digits
        return 90
    default:
        return 72
    }
}

