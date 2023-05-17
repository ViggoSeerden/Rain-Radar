//
//  GameView.swift
//  RainRadar
//
//  Created by Viggo Seerden on 10/05/2023.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        VStack {
            Image("logo")
                .resizable().frame(width: 361.2, height: 282.2)
        }
        .padding(2000)
        .background(Color(red: 69/255, green: 130/255, blue: 191/255))
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
