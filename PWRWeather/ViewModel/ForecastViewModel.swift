//
//  ForecastViewModel.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import SwiftUI
import CoreLocation

@MainActor
final class ForecastViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var dailyForecasts: [String: [Forecast]] = [:]
    @Published var isLoading = false
    @Published var isErrorState = false
    @Published var upcomingDailyData: [(id: UUID, weekDay: String, icon: String, minTemp: Int, maxTemp: Int)] = []
    @Published var hourlyData: [(id: UUID, time: String, icon: String, temperature: Int)] = []
    
    private var lastKnownLocation: CLLocation?
    
    func fetchForecast(forecastLocation: ForecastLocation?, deviceLocation: CLLocation?) {
        let (lat, lon) = determineLocation(forecastLocation: forecastLocation, deviceLocation: deviceLocation)
        
        Task {
            do {
                isLoading = true
                isErrorState = false
                weather = try await APIService.shared.getForecast(latitude: lat, longitude: lon)
                prepareUpcomingDailyData()
                prepareHourlyData()
                isLoading = false
            } catch {
                print("Forecast error:", error)
                isErrorState = true
                isLoading = false
            }
        }
    }
    
    private func determineLocation(forecastLocation: ForecastLocation?, deviceLocation: CLLocation?) -> (Double, Double) {
        if let loc = forecastLocation, !loc.address.isEmpty {
            return (loc.latitude, loc.longitude)
        }
        
        if let deviceLoc = deviceLocation {
            return (deviceLoc.coordinate.latitude, deviceLoc.coordinate.longitude)
        }
        
        return (55.751244, 37.618423) // default Moscow
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
    
    private func prepareHourlyData() {
        guard let forecast = weather?.forecast.forecastday, forecast.count > 0 else { return }
        
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        
        let todayHours = forecast[0].hour.filter {
            let hourDate = inputFormatter.date(from: $0.time) ?? Date()
            return calendar.component(.hour, from: hourDate) >= currentHour
        }
        
        let tomorrowHours = forecast.count > 1 ? forecast[1].hour : []
        let combinedHours = Array((todayHours + tomorrowHours).prefix(24))
        
        hourlyData = combinedHours.enumerated().map { index, hour in
            let date = inputFormatter.date(from: hour.time) ?? Date()
            let time = index == 0 ? "Сейчас" : outputFormatter.string(from: date)
            return (
                id: UUID(),
                time: time,
                icon: "https:\(hour.condition.icon)",
                temperature: Int(hour.temp_c)
            )
        }
    }
    
    func shouldUpdateLocation(to newLocation: CLLocation) -> Bool {
        guard let old = lastKnownLocation else {
            lastKnownLocation = newLocation
            return true
        }
        
        let distance = newLocation.distance(from: old)
        if distance >= 1000 {
            lastKnownLocation = newLocation
            return true
        }
        
        return false
    }
}
