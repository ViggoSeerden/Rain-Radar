//
//  MusicView.swift
//  RainRadar
//
//  Created by Viggo Seerden on 10/05/2023.
//

import SwiftUI
import MusicKit

struct MusicView: View {
    
    struct Item: Identifiable, Hashable {
        var id = UUID()
        let name: String
        let artist: String
        let imageUrl: URL?
    }
    
    @State var songs = [Item]()
    
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
    }
    
    private let request: MusicCatalogSearchRequest = {
        var request = MusicCatalogSearchRequest(term: "Rain", types: [Song.self])
        request.limit = 6
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


struct MusicView_Previews: PreviewProvider {
    static var previews: some View {
        MusicView()
    }
}
