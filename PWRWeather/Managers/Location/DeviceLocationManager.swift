//
//  DeviceLocationManager.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import Foundation
import MapKit

@MainActor
class DeviceLocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let deviceLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        deviceLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        deviceLocationManager.distanceFilter = 1000
        deviceLocationManager.delegate = self
        
        // Проверяем текущий статус авторизации
        authorizationStatus = deviceLocationManager.authorizationStatus
        
        // Запрашиваем разрешение только если оно еще не определено
        if authorizationStatus == .notDetermined {
            deviceLocationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            deviceLocationManager.startUpdatingLocation()
        }
    }
}

extension DeviceLocationManager : CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.location = location
            self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                deviceLocationManager.startUpdatingLocation()
            case .denied, .restricted:
                print("Location access denied")
            case .notDetermined:
                deviceLocationManager.requestWhenInUseAuthorization()
            @unknown default:
                break
            }
        }
    }
}

