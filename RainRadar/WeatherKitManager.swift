//
//  WeatherKitManager.swift
//  RainRadar
//
//  Created by Steijn on 19/04/2023.
//

import Foundation
import WeatherKit

@MainActor class WeatherKitManager: ObservableObject {
    
    @Published var weather: Weather?
    
    
    func getWeather(latitude: Double, longitude: Double) async {
            do {
                weather = try await Task.detached(priority: .userInitiated) {
                    return try await WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude))
                }.value
            } catch {
                fatalError("\(error)")
            }
        }
    
    var text: String {
        "The weather at your location is:"
    }
    
    var symbol: String {
        weather?.currentWeather.symbolName ?? ""
    }
    
    var temp: String {
        let temp =
        weather?.currentWeather.temperature
        
        let convert = temp?.converted(to: .celsius).description
        return convert ?? "Loading Weather Data"
    }
    
}
