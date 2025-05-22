//
//  ForecastLocation.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import Foundation
import MapKit

struct ForecastLocation: Identifiable, Equatable {
    let id = UUID()
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var name : String {
        self.mapItem.name ?? ""
    }
    
    var address: String {
        let placemark = self.mapItem.placemark
        var cityAndState = ""
        var address = ""
        
        cityAndState = placemark.locality ?? ""             // locality = city
        if let state = placemark.administrativeArea {       // administrativeArea = state
            cityAndState = cityAndState.isEmpty ? state : "\(cityAndState), \(state)"
        }
        
        address = placemark.subThoroughfare ?? ""           // subThoroughfare = address
        if let street = placemark.thoroughfare {
            address = address.isEmpty ? street : "\(address) \(street)"
        }
        
        if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {
            address = cityAndState
        } else {
            address = cityAndState.isEmpty ? address : "\(address), \(cityAndState)"
        }
        
        return address
    }
    
    var latitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.latitude
    }
    
    var longitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.longitude
    }
    
    // Conformance to Equatable
    static func == (lhs: ForecastLocation, rhs: ForecastLocation) -> Bool {
        lhs.id == rhs.id &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.address == rhs.address
    }
}
