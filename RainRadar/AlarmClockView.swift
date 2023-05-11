//
//  AlarmClockView.swift
//  RainRadar
//
//  Created by Steijn on 11/05/2023.
//

import SwiftUI

struct AlarmClockView: View {
    @State var text: Array<String> = []
    @State var showsheet = false
    @State var textitemtemp = ""
    @State var time = Date()
    
    var body: some View {
        NavigationView{
            VStack{
                Group{
                    if text.count <= 1 {
                        Text("You Have No Alarms")
                    } else {
                        List{
                            ForEach((1...text.count-1), id: \.self) {
                                i in Text(text[i])
                                    .contextMenu {
                                        Button(action: {
                                            text.remove(at: i)
                                        }, label: {
                                            Label("Delete", systemImage: "delete.left")
                                        })
                                    }
                            }}
                    }
                }
                .navigationTitle("Alarm")
                .toolbar{
                    Button(action: {
                        showsheet.toggle()
                        //clear the temp
                        textitemtemp = ""
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                .onChange(of: text) { _ in
                    saveData()
                    loadData()
                }
                .onAppear(){
                    saveData()
                    loadData()
                }
                .refreshable {
                    saveData()
                    loadData()
                }
            }
            .sheet(isPresented: $showsheet) {
                NavigationView{
                    List{
                        Section(header:(Text("Alarm"))) {
                            TextField("Alarm Name:", text: $textitemtemp)
                            DatePicker("Pick A Time:", selection: $time, displayedComponents: .hourAndMinute)
                                    }
                    }
                    .navigationTitle("Add A Alarm")
                    .toolbar{
                        Button("Add"){
                            text.append(textitemtemp)
                            showsheet.toggle()
                        }
                    }
                }
            }
        }
    }
    func saveData() -> Void {
        let temp = text.joined(separator: "/[split]/")
        let key = UserDefaults.standard
        key.set(temp, forKey: "text")
    }
    
    func loadData() -> Void {
        let key = UserDefaults.standard
        let temp = key.string(forKey: "text") ?? ""
        let temparray = temp.components(separatedBy: "/[split]/")
        text = temparray
    }
}

struct AlarmClockView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmClockView()
    }
}
