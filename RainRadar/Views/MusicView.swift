//
//  MusicView.swift
//  RainRadar
//
//  Created by Viggo Seerden on 10/05/2023.
//

import SwiftUI
import MusicKit
import WeatherKit

struct MusicView: View {
    
    struct Item: Identifiable, Hashable {
        var id = UUID()
        let name: String
        let artist: String
        let imageUrl: URL?
    }
    
    @State var songs = [Item]()
    @ObservedObject var weatherKitManager = WeatherKitManager()
    @StateObject var locationDataManager = LocationDataManager()

    
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
            }.navigationTitle("Songs")
        }.onAppear(){
            fetchMusic()
        }
    }
    
    private func fetchMusic() {
        Task {
            // Request Permission
            let musicAuthorizationStatus = await MusicAuthorization.request()
            
            if case .authorized = musicAuthorizationStatus {
                // Fetch Weather
                do {
                    await weatherKitManager.getWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                    let weatherCondition = weatherKitManager.condition
                    
                    //Modify search term based on weather condition
                    var searchRequest = MusicCatalogSearchRequest(term: weatherCondition, types: [Song.self])
                    searchRequest.limit = 10
                    
                     //Request -> Response
                    do {
                        let result = try await searchRequest.response()
                        self.songs = result.songs.compactMap { song in
                            return Item(name: song.title, artist: song.artistName, imageUrl: song.artwork?.url(width: 75, height: 75))
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
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


struct MusicView_Previews: PreviewProvider {
    static var previews: some View {
        MusicView()
    }
}
