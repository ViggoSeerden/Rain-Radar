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
            Text(weatherKitManager.text)
            Label(weatherKitManager.temp, systemImage: weatherKitManager.symbol)
                .task {
                    await weatherKitManager.getWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                }
        } else {
            Text("Error Loading Location")
        }
    }
}
