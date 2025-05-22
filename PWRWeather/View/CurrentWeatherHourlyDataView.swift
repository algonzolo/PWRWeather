//
//  CurrentWeatherHourlyDataView.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import SwiftUI

struct CurrentWeatherHourlyDataView: View {
    var hourlyData: [(id: UUID, time: String, icon: String, temperature: Int)]
    
    var body: some View {
        VStack(alignment: .leading) {
            (Text(Image(systemName: "clock.fill")) + Text("  Hourly Forecast".uppercased()))
                .font(.system(size: 12))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.6))
            
            Divider()
                .overlay(Color.white)
                .padding(.bottom, 10)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(hourlyData, id: \.id) { hour in
                        VStack {
                            Text(hour.time)
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            AsyncImage(url: URL(string: hour.icon)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 45, height: 45)
                            .padding(.vertical, 4)
                            
                            Text("\(hour.temperature)°")
                                .font(.system(size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 14)
                    }
                }
            }.scrollIndicators(.never)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16.0)
                .fill(Color.darkBlue.opacity(0.38))
        )
    }
}

