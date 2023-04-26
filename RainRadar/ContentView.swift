//
//  ContentView.swift
//  RainRadar
//
//  Created by Steijn on 19/04/2023.
//

import SwiftUI
import WeatherKit

struct ContentView: View {
    @ObservedObject var weatherKitManager = WeatherKitManager()
    @StateObject var locationDataManager = LocationDataManager()
    
    var hourlyForecastByDate: [Date: [HourWeather]] {
        guard let hourlyForecast = weatherKitManager.hourlyForecast else { return [:] }
        return Dictionary(grouping: hourlyForecast.dropFirst(11), by: { Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: $0.date)! })
    }
    
    var sortedDates: [Date] {
        hourlyForecastByDate.keys.sorted()
    }
    
    var body: some View {
        if locationDataManager.authorizationStatus == .authorizedWhenInUse {
            VStack {
                Text(weatherKitManager.text)
                Label(weatherKitManager.temp, systemImage: weatherKitManager.symbol)
                    .task {
                        await weatherKitManager.getWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                        await weatherKitManager.getHourlyForecast(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                    }
                
                if !hourlyForecastByDate.isEmpty {
                    TabView {
                        ForEach(sortedDates, id: \.self) { date in
                            if let weatherEntries = hourlyForecastByDate[date] {
                                ScrollView {
                                    ForEach(weatherEntries, id: \.self.date) { weatherEntry in
                                        HStack {
                                            Text(DateFormatter.localizedString(from: weatherEntry.date, dateStyle: .short, timeStyle: .short))
                                            Spacer()
                                            Image(systemName: weatherEntry.symbolName)
                                            Text(weatherKitManager.convertTemp(temperature: weatherEntry.temperature))
                                        }
                                    }
                                }
                                .frame(width: 300, height: 600)
                                .tabItem { Text(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)) }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
            }
        }
        else {
            Text("Error Loading Location:")
        }
    }
}
