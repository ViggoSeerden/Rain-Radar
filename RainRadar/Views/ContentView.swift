//
//  ContentView.swift
//  RainRadar
//
//  Created by Steijn on 19/04/2023.
//

import SwiftUI
import MusicKit
import WeatherKit
import SpriteKit

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
        NavigationView{
            if locationDataManager.authorizationStatus == .authorizedWhenInUse {
                VStack {
                    VStack {
                        Text(weatherKitManager.text)
                            
                        Label(weatherKitManager.temp, systemImage: weatherKitManager.symbol)
                            .padding(.bottom, 10)
                            .task {
                                await weatherKitManager.getWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                                await weatherKitManager.getHourlyForecast(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                            }
                        Text("Rainfall for today: \(weatherKitManager.rain) mm/hour")
                        Text(weatherKitManager.analogy)
                    }
                    .padding(20)
                    .border(Color(UIColor.systemBackground))
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20)
                    .padding(.top, 50)
                    
                    if !hourlyForecastByDate.isEmpty {
                        TabView {
                            ForEach(sortedDates, id: \.self) { date in
                                if let weatherEntries = hourlyForecastByDate[date] {
                                    ScrollView {
                                        Text(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)).padding(.bottom, 10)
                                        ForEach(weatherEntries, id: \.self.date) {
                                            weatherEntry in HStack {
                                                Text(DateFormatter.localizedString(from: weatherEntry.date, dateStyle: .none, timeStyle: .short))
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
                            .padding(.vertical, 20)
                            .padding(.horizontal, 25)
                            .border(Color(UIColor.systemBackground))
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(20)
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                    }
                }
            }
            else {
                Text("Error Loading Location:")
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .background(weatherKitManager.condition.contains("Rain") ?
                    AnyView(SpriteView(scene: Rainfall(), options: [.allowsTransparency])) :
                    AnyView(Color.clear))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class Rainfall: SKScene{
    override func sceneDidLoad() {
        size = UIScreen.main.bounds.size
        scaleMode = .resizeFill
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let node = SKEmitterNode(fileNamed: "Rainfall.sks")!
        addChild(node)
    }
}
