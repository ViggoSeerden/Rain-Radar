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
    @Published var hourlyForecast: Forecast<HourWeather>?
    
    
    func getWeather(latitude: Double, longitude: Double) async {
        do {
            weather = try await Task.detached(priority: .userInitiated) {
                return try await WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude))
            }.value
        } catch {
            fatalError("\(error)")
        }
    }
    
    func getHourlyForecast(latitude: Double, longitude: Double) async {
        Task.detached(priority: .userInitiated) {
            do {
                let forcast = try await WeatherService.shared.weather(
                    for: .init(latitude: latitude, longitude: longitude),
                    including: .hourly)
                DispatchQueue.main.async {
                    self.hourlyForecast = forcast
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var text: String {
        "The current weather at your location is:"
    }
    
    var symbol: String {
        weather?.currentWeather.symbolName ?? ""
    }
    
    var condition: String {
        weather?.currentWeather.condition.description ?? ""
    }
    
    var temp: String {
        let temp =
        weather?.currentWeather.temperature
        
        let convert = temp?.converted(to: .celsius).description
        return convert ?? "Loading Weather Data..."
    }
    
    var rain: String {
        if let rain =
            weather?.dailyForecast.forecast.first?.precipitationAmount.value {
            let mm = Measurement(value: rain, unit: UnitLength.millimeters).value
            let duration = Measurement(value: 1, unit: UnitDuration.hours).value
            let answer = mm / duration
            return String(format: "%.2f", answer)
        }
        else {
            return "Tough Luck, Ass Wipe"
        }
    }
    
    var analogy: String {
        if rain != "Tough Luck, Ass Wipe" {
           if let rain2 = Double(rain) {
                switch rain2 {
                case 0...1:
                    return "Dryer than your girlfriend"
                case 1...5:
                    return "Quite moist out innit"
                case 5...10:
                    return "It's raining men, hallelujah"
                case 10...100:
                    return "EVERY MAN FOR HIMSELF"
                default:
                    return "nuthin'"
                }
            }
            else {
                return ""
            }
        }
        else {
            return ""
        }
    }
    
    var object: String {
        return ""
    }
    
    var music: String {
        return ""
    }
    
    func convertTemp(temperature: Measurement<UnitTemperature>) -> String {
        let convert = temperature.converted(to: .celsius).value
        return String(format: "%.1f", convert)
    }
    
    func convertRain(rain: Double) -> String {
        let convert = Measurement(value: rain, unit: UnitLength.millimeters).value
        return String(format: "%.1f", convert) + " mm"
    }
}
