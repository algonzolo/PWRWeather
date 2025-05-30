//
//  CurrentWeatherSummaryView.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import SwiftUI

struct CurrentWeatherSummaryView: View {
    var cityName: String
    var currentTemperature: Int
    var weatherDescription: String
    var icon: String
    var highTemperature: Int
    var lowTemperature: Int
    
    @Binding var isEditingLocation: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                isEditingLocation.toggle()
            }) {
                HStack(spacing: 5) {
                    Text(cityName)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .shadow(radius: 2.0)
                    
                    Image(systemName: "pencil")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }
            
            ZStack {
                Text("\(currentTemperature)")
                    .font(.system(size: 100))
                    .fontWeight(.thin)
                    .foregroundColor(.white)
                    .shadow(radius: 2.0)
                
                Text("°")
                    .font(.system(size: 90))
                    .fontWeight(.thin)
                    .foregroundColor(.white)
                    .shadow(radius: 2.0)
                    .offset(x: degreeSymbolOffsetX(for: currentTemperature), y: -4)
            }
            
            .padding(.bottom, -20)
            
            HStack(spacing: 2) {
                AsyncImage(url: URL(string: "https:" + (icon))) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 45, height: 45)
                
                Text(weatherDescription)
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .shadow(radius: 2.0)
                    .foregroundColor(.white)
                    .shadow(radius: 2.0)
            }
            
            Text("Max:\(highTemperature)° Min:\(lowTemperature)°")
                .font(.system(size: 18))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .shadow(radius: 2.0)
        }
    }
}
