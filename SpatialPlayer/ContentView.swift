//
//  ContentView.swift
//  SpatialPlayer
//
//  Created by Michael Swanson on 2/6/24.
//

import SwiftUI

protocol ReplayViewDelegate: AnyObject {
    func didReplay()
}

struct ContentView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        ZStack {
            switch viewModel.appView {
            case .WELCOME:
                WelcomeView()
            case .VIDEO_PREVIEW:
                VideoPreviewView()
            case .IMMERSIVE_VIEW:
                EmptyView()
            case .RATING_VIEW:
                WelcomeView()
            case .ENDING_VIEW:
                EndingView()
            }
        }
//        .controlSize(.large)
        .onChange(of: viewModel.isImmersiveSpaceShown) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "PlayerImmersiveSpace") {
                    case .opened:
                        viewModel.isImmersiveSpaceShown = true
                    default:
                        viewModel.isImmersiveSpaceShown = false
                    }
                } else {
                    await dismissImmersiveSpace()
                    viewModel.isImmersiveSpaceShown = false
                }
            }
        }
        .padding()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(PlayerViewModel())
//    }
//}
