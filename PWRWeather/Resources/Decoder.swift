//
//  Decoder.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import Foundation

enum Key {
    static var weatherAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String else {
            fatalError("Weather API key not found in Info.plist")
        }
        
        return key
    }
}
