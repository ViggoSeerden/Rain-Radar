//
//  MainView.swift
//  RainRadar
//
//  Created by Viggo Seerden on 10/05/2023.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Weather", systemImage: "cloud")
                }
            AlarmClockView()
                .tabItem {
                    Label("Alarm", systemImage: "alarm.fill")
                }
            MusicView()
                .tabItem {
                    Label("Music", systemImage: "music.note")
                }
            GameView()
                .tabItem {
                    Label("Game", systemImage: "gamecontroller.fill")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
