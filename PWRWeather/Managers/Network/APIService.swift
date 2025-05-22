//
//  APIService.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import Foundation

final class APIService {
    static let shared = APIService()
    
    static let baseURL = "https://api.weatherapi.com/v1/"
    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    
    private init() {}
    
    func getForecast(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let forecastURLString = "\(APIService.baseURL)forecast.json?key=\(apiKey)&q=\(latitude),\(longitude)&days=7"
        
        guard let url = URL(string: forecastURLString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            let decodedResponse = try decoder.decode(WeatherResponse.self, from: data)
            return decodedResponse
        } catch {
            print(error)
            throw APIError.invalidData
        }
    }
}

