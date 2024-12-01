//
//  ContentView.swift
//  autosteer
//
//  Created by David Rodríguez Fernández on 17/11/24.
//

import SwiftUI
struct ContentView: View {
    var body: some View {
        TabView {
             Principal()
                 .tabItem {
                     Label("Principal", systemImage: "map.circle")
                 }


             Ajustes()
                 .tabItem {
                     Label("Ajustes", systemImage: "gear.circle")
                 }
           /*
             RoadBook()
                 .tabItem {
                     Label("Road Book", systemImage: "book")
                 }
             */
         }
    }
}

#Preview {
    ContentView()
}
