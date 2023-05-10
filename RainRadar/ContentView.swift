//
//  ContentView.swift
//  RainRadar
//
//  Created by Steijn on 19/04/2023.
//

import SwiftUI
import MusicKit
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
        VStack{
            if locationDataManager.authorizationStatus == .authorizedWhenInUse {
                VStack {
                    VStack {
                        Text(weatherKitManager.text)
                            
                        Label(weatherKitManager.temp, systemImage: weatherKitManager.symbol)
                            .task {
                                await weatherKitManager.getWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                                await weatherKitManager.getHourlyForecast(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                            }
                        Text("\(weatherKitManager.rain) mm/hour")
                        Text(weatherKitManager.analogy)
                    }
                    .padding(20)
                    .border(Color(UIColor.systemBackground))
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20)
                    .padding(10)
                    
                    if !hourlyForecastByDate.isEmpty {
                        TabView {
                            ForEach(sortedDates, id: \.self) { date in
                                if let weatherEntries = hourlyForecastByDate[date] {
                                    ScrollView {
                                        ForEach(weatherEntries, id: \.self.date) {
                                            weatherEntry in HStack {
                                                Text(DateFormatter.localizedString(from: weatherEntry.date, dateStyle: .short, timeStyle: .short))
                                                Spacer()
                                                Image(systemName: weatherEntry.symbolName)
                                                Text(weatherKitManager.convertTemp(temperature: weatherEntry.temperature))
                                                Spacer()
                                                Text(weatherKitManager.convertRain(rain: weatherEntry.precipitationAmount.value))
                                            }
                                        }
                                    }
                                    .frame(width: 300, height: 400)
                                    .tabItem { Text(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)) }
                                }
                            }
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .padding(10)
                        .border(Color(UIColor.systemBackground))
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(20)
                        .padding(27)
                    }
                }
            }
            else {
                Text("Error Loading Location:")
            }
        }.background(Color(UIColor.secondarySystemBackground))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
