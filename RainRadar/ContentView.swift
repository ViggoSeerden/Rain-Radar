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
    

    struct Item: Identifiable, Hashable {
        var id = UUID()
        let name: String
        let artist: String
        let imageUrl: URL?
    }
    
    @State var songs = [Item]()
    
    var hourlyForecastByDate: [Date: [HourWeather]] {
        guard let hourlyForecast = weatherKitManager.hourlyForecast else { return [:] }
        return Dictionary(grouping: hourlyForecast.dropFirst(11), by: { Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: $0.date)! })
    }
    
    var sortedDates: [Date] {
        hourlyForecastByDate.keys.sorted()
    }
    
    var body: some View {
        NavigationStack{
            List(songs) {
                song in HStack{
                    AsyncImage(url: song.imageUrl)
                        .frame(width: 75, height: 75, alignment: .center)
                    VStack(alignment: .leading){
                        Text(song.name)
                            .font(.title3)
                        Text(song.artist)
                            .font(.footnote)
                    }.padding()
                }
            }
        }.onAppear(){
            fetchMusic()
        }
        
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
    private let request: MusicCatalogSearchRequest = {
        var request = MusicCatalogSearchRequest(term: "Flowers", types: [Song.self])
        request.limit = 10
        return request
    }()
    
    private func fetchMusic(){
        Task{
            //Request Permission
            let status = await MusicAuthorization.request()
            switch status{
            case .authorized:
                //Request -> Response
                do{
                    let result = try await request.response()
                    self.songs = result.songs.compactMap({
                        return .init(name: $0.title, artist:$0.artistName, imageUrl: $0.artwork?.url(width: 75, height: 75))
                    })
                    print(String(describing: songs[0]))
                }catch{
                    print(String(describing: error))
                }
                //Assign Song
                
            default:
                break
            }

            }
        }
}
