//
//  ContentView.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isNight = false
    @State private var forecastLocation = ForecastLocation(mapItem: MKMapItem())
    @State private var isEditingLocation = false
    @EnvironmentObject var deviceLocationManager: DeviceLocationManager
    @StateObject var forecastViewModel = ForecastViewModel()
    private var locationStorage = LocationStorage()
    
    var body: some View {
        ZStack {
            BackgroundView(isNight: $isNight)
            VStack {
                if deviceLocationManager.authorizationStatus == .denied || deviceLocationManager.authorizationStatus == .restricted {
                    HStack {
                        Text("Для работы приложения необходим доступ к геолокации")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .shadow(radius: 2.0)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity)
                }
                
                if forecastViewModel.isLoading {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .darkBlue))
                            .scaleEffect(3)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                if forecastViewModel.isErrorState {
                    HStack {
                        Text("Ошибка при получении прогноза")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .shadow(radius: 2.0)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        Text("Пожалуйста, попробуйте позже!")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .shadow(radius: 2.0)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity)
                }
                
                if let forecast = forecastViewModel.weather {
                    CurrentWeatherSummaryView(
                        cityName: forecast.location.name,
                        currentTemperature: Int(forecast.current.temp_c),
                        weatherDescription: forecast.current.condition.text,
                        highTemperature: Int(forecast.forecast.forecastday[0].day.maxtemp_c),
                        lowTemperature: Int(forecast.forecast.forecastday[0].day.mintemp_c),
                        isEditingLocation: $isEditingLocation
                    )
                    .padding(.top, 15)
                    .padding(.bottom, 30)
                    
                    CurrentWeatherHourlyDataView(
                        hourlyData: {
                            let now = Date()
                            let calendar = Calendar.current
                            let currentHour = calendar.component(.hour, from: now)
                            
                            // Formatters
                            let inputFormatter = DateFormatter()
                            inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                            
                            let outputFormatter = DateFormatter()
                            outputFormatter.dateFormat = "HH:mm"
                            
                            // Часы на сегодня (оставшиеся, начиная с текущего)
                            let todayHours = forecast.forecast.forecastday[0].hour.filter {
                                let hourDate = inputFormatter.date(from: $0.time) ?? Date()
                                return calendar.component(.hour, from: hourDate) >= currentHour
                            }
                            
                            // Часы на завтра (второй день прогноза)
                            let tomorrowHours = forecast.forecast.forecastday.count > 1
                            ? forecast.forecast.forecastday[1].hour
                            : []
                            
                            // Объединение: сегодня + завтра, но не больше 24
                            let combinedHours = Array((todayHours + tomorrowHours).prefix(24))
                            
                            return combinedHours.enumerated().map { index, hour in
                                let date = inputFormatter.date(from: hour.time) ?? Date()
                                let time = index == 0 ? "Сейчас" : outputFormatter.string(from: date)
                                
                                let iconURL = "https:" + (hour.condition.icon)
                                
                                return (
                                    id: UUID(),
                                    time: time,
                                    icon: iconURL,
                                    temperature: Int(hour.temp_c)
                                )
                            }
                        }()
                    )
                    .padding(.bottom, 15)
                    
                    UpcomingDailyForecastView(dailyData: forecastViewModel.upcomingDailyData)
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
            .onAppear {
                isNight = isNightTimeNow()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    fetchForecast()
                }
            }
            .onChange(of: deviceLocationManager.location) { oldLocation, newLocation in
                guard let newLocation = newLocation else { return }
                
                // Проверяем, изменилась ли локация значительно (более чем на 1 км)
                if let oldLocation = oldLocation {
                    let distance = newLocation.distance(from: oldLocation)
                    if distance < 1000 { // 1 километр
                        return
                    }
                }
                
                fetchForecast()
            }
            .onChange(of: forecastLocation) { oldForecastLocation, newForecastLocation in
                saveLocation()
                fetchForecast()
            }
        }
        
        .fullScreenCover(isPresented: $isEditingLocation) {
            ForecastLocationSearchView(forecastLocation: $forecastLocation, isEditingLocation: $isEditingLocation)
        }
    }
    
    private func fetchForecast() {
        let (latitude, longitude) = determineLocation()
        forecastViewModel.getForecastData(latitude: latitude, longitude: longitude)
    }
    
    private func determineLocation() -> (Double, Double) {
        // First try to get device location
        if let deviceLat = deviceLocationManager.location?.coordinate.latitude,
           let deviceLon = deviceLocationManager.location?.coordinate.longitude {
            return (deviceLat, deviceLon)
        }
        
        // If device location is not available, try saved location
        let lastLocation = locationStorage.getLastLocation()
        if let latitude = lastLocation.latitude, let longitude = lastLocation.longitude {
            return (latitude, longitude)
        }
        
        // If neither device nor saved location is available, use forecast location or default
        if !forecastLocation.address.isEmpty {
            return (forecastLocation.latitude, forecastLocation.longitude)
        } else {
            return (55.751244, 37.618423) // Moscow location
        }
    }
    
    private func saveLocation() {
        locationStorage.saveLocation(latitude: forecastLocation.latitude, longitude: forecastLocation.longitude)
        print("Stored latitude: \(forecastLocation.latitude) and longitude: \(forecastLocation.longitude) locally.")
    }
}

struct BackgroundView: View {
    
    @Binding var isNight: Bool
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [isNight ? .black : .blue, isNight ? .gray : Color("lightBlue")]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
        .edgesIgnoringSafeArea(.all)
    }
}
