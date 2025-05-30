//
//  PWRWeatherApp.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import SwiftUI

@main
struct WeatherNowApp: App {
    var body: some Scene {
        WindowGroup {
            ForecastView()
                .environmentObject(DeviceLocationManager())
        }
    }
}
