//
//  ForecastViewModel.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import SwiftUI

@MainActor final class ForecastViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var dailyForecasts: [String: [Forecast]] = [:]
    @Published var isLoading = false
    @Published var isErrorState = false
    @Published var upcomingDailyData: [(id: UUID, weekDay: String, icon: String, minTemp: Int, maxTemp: Int)] = []
    
    func getForecastData(latitude: Double, longitude: Double) {
        Task {
            do {
                isLoading = true
                
                weather = try await APIService.shared.getForecast(latitude: latitude, longitude: longitude)
                print("Forecast fetch succeeded for \(weather?.location.name ?? "Unknown")")
                prepareUpcomingDailyData()
                isLoading = false
            } catch {
                print("Error fetching weather:", error)
                isErrorState = true
                isLoading = false
            }
        }
    }
    
    private func prepareUpcomingDailyData() {
        guard let forecastDays = weather?.forecast.forecastday else { return }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEEE"
        
        upcomingDailyData = forecastDays.map { day in
            let date = inputFormatter.date(from: day.date) ?? Date()
            let weekDay = outputFormatter.string(from: date)
            let icon = "https:\(day.day.condition.icon)"
            
            return (
                id: UUID(),
                weekDay: weekDay,
                icon: icon,
                minTemp: Int(day.day.mintemp_c),
                maxTemp: Int(day.day.maxtemp_c)
            )
        }
    }
}
