//
//  APIError.swift
//  PWRWeather
//
//  Created by Albert Garipov on 22.05.2025.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case unableToComplete
}
