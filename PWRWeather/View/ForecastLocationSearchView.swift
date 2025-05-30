//
//  ForecastLocationSearchView.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import SwiftUI

struct ForecastLocationSearchView: View {
    @EnvironmentObject var locationManager: DeviceLocationManager
    @State var forecastLocationViewModel = ForecastLocationViewModel()
    
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    @Binding var forecastLocation: ForecastLocation
    @Binding var isEditingLocation: Bool
    
    var body: some View {
        NavigationView {
            List(forecastLocationViewModel.forecastLocations) { location in
                VStack {
                    Text(location.name)
                        .font(.title2)
                    Text(location.address)
                        .font(.callout)
                }
                .onTapGesture {
                    forecastLocation = location
                    isEditingLocation.toggle()
                    dismiss()
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    forecastLocationViewModel.search(text: newValue, region: locationManager.region)
                }
            }
            .navigationBarItems(trailing:
                                    Button("Dismiss") {
                isEditingLocation.toggle()
                dismiss()
            }
            )
        }
    }
}
