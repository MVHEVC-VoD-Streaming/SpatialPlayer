//
//  VideoPreviewView.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/4.
//

import SwiftUI

struct VideoPreviewView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    weak var replayDelegate: ReplayViewDelegate?

    var body: some View {
        VStack {
            Text("Current Video: \(viewModel.currentVideoIndex + 1) / \(viewModel.videoURLPlaylist.count)").bold()
            
            Button("Play", systemImage: "play.fill") {
                viewModel.appView = AppView.IMMERSIVE_VIEW
                viewModel.isImmersiveSpaceShown = true
            }
            .padding()
            
            Button("Quit") {
                viewModel.appView = AppView.WELCOME
                viewModel.isImmersiveSpaceShown = false
                // TODO: clean up logic
            }
        }
    }
}

//struct VideoPreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPreviewView()
//            .environmentObject(PlayerViewModel())
//    }
//}
