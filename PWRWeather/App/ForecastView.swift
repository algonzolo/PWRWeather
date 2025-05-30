//
//  ForecastView.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import SwiftUI
import MapKit

struct ForecastView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isNight = false
    @State private var forecastLocation = ForecastLocation(mapItem: MKMapItem())
    @State private var isEditingLocation = false
    @EnvironmentObject var deviceLocationManager: DeviceLocationManager
    @StateObject var forecastViewModel = ForecastViewModel()
    
    var body: some View {
        ZStack {
            BackgroundView(isNight: $isNight)
            VStack {
                locationPermissionMessage
                loadingOrErrorViews
                
                if let weather = forecastViewModel.weather {
                    CurrentWeatherSummaryView(
                        cityName: weather.location.name,
                        currentTemperature: Int(weather.current.temp_c),
                        weatherDescription: weather.current.condition.text,
                        icon: weather.current.condition.icon,
                        highTemperature: Int(weather.forecast.forecastday[0].day.maxtemp_c),
                        lowTemperature: Int(weather.forecast.forecastday[0].day.mintemp_c),
                        isEditingLocation: $isEditingLocation
                    )
                    .padding(.vertical, 15)
                    
                    CurrentWeatherHourlyDataView(
                        description: "Around \(weather.forecast.forecastday[0].day.avgtemp_c)°C over the next few hours. Wind up to \(weather.forecast.forecastday[0].day.maxwind_kph) km/h, humidity at \(weather.forecast.forecastday[0].day.avghumidity)%.",
                        hourlyData: forecastViewModel.hourlyData
                    )
                    .padding(.bottom, 15)
                    
                    UpcomingDailyForecastView(dailyData: forecastViewModel.upcomingDailyData)
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
            .onAppear {
                isNight = isNightTimeNow()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    forecastViewModel.fetchForecast(forecastLocation: forecastLocation, deviceLocation: deviceLocationManager.location)
                }
            }
            .onChange(of: deviceLocationManager.location) { newLocation in
                guard let newLocation = newLocation,
                      forecastViewModel.shouldUpdateLocation(to: newLocation) else { return }
                
                forecastViewModel.fetchForecast(forecastLocation: forecastLocation, deviceLocation: newLocation)
            }
            .onChange(of: forecastLocation) { newLocation in
                forecastViewModel.fetchForecast(forecastLocation: newLocation, deviceLocation: deviceLocationManager.location)
            }
        }
        .fullScreenCover(isPresented: $isEditingLocation) {
            ForecastLocationSearchView(forecastLocation: $forecastLocation, isEditingLocation: $isEditingLocation)
        }
    }
    
    private var locationPermissionMessage: some View {
        Group {
            if deviceLocationManager.authorizationStatus == .denied || deviceLocationManager.authorizationStatus == .restricted {
                Text("Для работы приложения необходим доступ к геолокации")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .shadow(radius: 2.0)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var loadingOrErrorViews: some View {
        Group {
            if forecastViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .darkBlue))
                    .scaleEffect(3)
                    .frame(maxWidth: .infinity)
            }
            
            if forecastViewModel.isErrorState {
                VStack(spacing: 5) {
                    Text("Ошибка при получении прогноза")
                    Text("Пожалуйста, попробуйте позже!")
                }
                .font(.system(size: 18))
                .foregroundColor(.white)
                .shadow(radius: 2.0)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct BackgroundView: View {
    @Binding var isNight: Bool
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [isNight ? .black : .blue, isNight ? .gray : Color.lightBlue]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
        .edgesIgnoringSafeArea(.all)
    }
}
