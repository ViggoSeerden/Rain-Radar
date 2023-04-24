//
//  ContentView.swift
//  RainRadar
//
//  Created by Steijn on 19/04/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var weatherKitManager = WeatherKitManager()
    @StateObject var locationDataManager = LocationDataManager()
    
    var body: some View {
        if locationDataManager.authorizationStatus == .authorizedWhenInUse {
            VStack {
                Text(weatherKitManager.text)
                Label(weatherKitManager.temp, systemImage: weatherKitManager.symbol)
                    .task {
                        await weatherKitManager.getWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                        await weatherKitManager.getHourlyForecast(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                    }
                
                if let hourlyWeather = weatherKitManager.hourlyForecast {
                    ScrollView {
                        ForEach(hourlyWeather, id: \.self.date) { weatherEntry in
                            HStack {
                                Text(DateFormatter.localizedString(from: weatherEntry.date, dateStyle: .short, timeStyle: .short))
                                Spacer()
                                Image(systemName: weatherEntry.symbolName)
                                Text(weatherKitManager.convertTemp(temperature: weatherEntry.temperature))
                            }
                        }
                    }
                    .frame(width: 300, height: 600)
                }
            }
        }
        else {
            Text("Error Loading Location:")
        }
    }
}
