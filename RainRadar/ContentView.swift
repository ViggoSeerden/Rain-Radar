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
                    NavigationLink(destination: SongDetailView(song: song), label: {
                        AsyncImage(url: song.imageUrl)
                            .frame(width: 75, height: 75, alignment: .center)
                        VStack(alignment: .leading){
                            Text(song.name)
                                .font(.title3)
                            Text(song.artist)
                                .font(.footnote)
                        }.padding()
                    })
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
                Text("\(weatherKitManager.rain) mm/hour")
                Text(weatherKitManager.analogy)
                
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
                                            Spacer()
                                            Text(weatherKitManager.convertRain(rain: weatherEntry.precipitationAmount.value))
                                        }
                                    }
                                }
                                .frame(width: 300, height: 280)
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
    
    struct SongDetailView: View {
        
        let song: Item
        
        var body: some View {
            VStack {
                AsyncImage(url: song.imageUrl) {image in
                    image
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                } placeholder: {
                    Rectangle()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .background(Color(UIColor.secondarySystemBackground))
                }
                    .frame(width: 200, height: 200, alignment: .center)
                VStack{
                    Text(song.name)
                        .font(.title)
                    Text(song.artist)
                        .font(.title3)
                }.padding()
                }
            }
        }
    }


