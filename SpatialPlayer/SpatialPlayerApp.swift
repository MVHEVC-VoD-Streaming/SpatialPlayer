//
//  SpatialPlayerApp.swift
//  SpatialPlayer
//
//  Created by Michael Swanson on 2/6/24.
//

import SwiftUI

@main
struct SpatialPlayerApp: App {
    @StateObject private var viewModel = PlayerViewModel()
    
    
    var body: some SwiftUI.Scene {
        WindowGroup(id: "MainWindowGroup") {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 800, minHeight: 400)
                .environment(\.titleFont, .system(size: 32, weight: .bold))
                .environment(\.contentFont, .system(size: 26))
        }
        .windowStyle(.plain)
        .windowResizability(.automatic)


        
        ImmersiveSpace(id: "PlayerImmersiveSpace") {
            ImmersiveView()
                .environmentObject(viewModel)
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
