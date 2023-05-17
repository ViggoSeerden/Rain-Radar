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
                        Text("Eindhoven")
                            .font(.largeTitle)
                            .foregroundColor(Color.white)
                        Image(systemName: "\(weatherKitManager.symbol).fill")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Text(weatherKitManager.temp)
                            .padding(.bottom, 10)
                            .font(.title)
                            .foregroundColor(Color.white)
                            .task {
                                await weatherKitManager.getWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                                await weatherKitManager.getHourlyForecast(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                            }
                        //Text("Rainfall for today: \(weatherKitManager.rain) mm/hour")
                            //.foregroundColor(Color.white)
                        Text(weatherKitManager.analogy)
                            .foregroundColor(Color.white)
                    }
                    .padding(.horizontal, 80)
                    .padding(.vertical, 10)
                    .background(Color(red: 30/255, green: 110/255, blue: 180/255))
                    .cornerRadius(20)
                    .padding(.top, 50)
                    
                    if !hourlyForecastByDate.isEmpty {
                        TabView {
                            ForEach(sortedDates, id: \.self) { date in
                                if let weatherEntries = hourlyForecastByDate[date] {
                                    ScrollView {
                                        VStack(spacing: 10){
                                            Text(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none))
                                                .padding(.top, 25)
                                                .padding(.bottom, 10)
                                                .font(.title)
                                                .foregroundColor(Color.white)
                                            ForEach(weatherEntries, id: \.self.date) {
                                                weatherEntry in HStack {
                                                    Text(DateFormatter.localizedString(from: weatherEntry.date, dateStyle: .none, timeStyle: .short))
                                                        .foregroundColor(Color.white)
                                                    Spacer()
                                                    Image(systemName: "\(weatherEntry.symbolName).fill")
                                                        .symbolRenderingMode(.multicolor)
                                                    Text(weatherKitManager.convertTemp(temperature: weatherEntry.temperature))
                                                        .foregroundColor(Color.white)
                                                    Spacer()
                                                    Text(weatherKitManager.convertRain(rain: weatherEntry.precipitationAmount.value))
                                                        .foregroundColor(Color.white)
                                                }
                                            }
                                        }
                                    }
                                    .frame(width: 300, height: 300)
                                    .tabItem { Text(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)) }
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 25)
                            .background(Color(red: 30/255, green: 110/255, blue: 180/255))

                            .cornerRadius(20)
                            

                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                    }
                }
                .background(Color(red: 69/255, green: 130/255, blue: 191/255))
            }
            else {
                Text("Error Loading Location:")
            }
        }
        .background(Color(red: 69/255, green: 130/255, blue: 191/255))
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
