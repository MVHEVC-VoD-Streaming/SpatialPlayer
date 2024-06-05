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
    
    var currentVideoURL: URL? {
        if let sessionData = viewModel.sessionData {
            let item = sessionData.data.playlist[viewModel.currentVideoIndex]
            
            return URL(string: "\(viewModel.serverDomain)\(item.url)")
        }
        return nil
    }

    var body: some View {
        VStack {
            Text("Current Video: \(viewModel.currentVideoIndex + 1) / \(viewModel.playlist.count)").bold()
            
            Button("Play", systemImage: "play.fill") {
                guard let videoURL = currentVideoURL else {
                    print("No video URL selected")
                    return
                }
                viewModel.appView = AppView.IMMERSIVE_VIEW
                viewModel.videoURL = videoURL
                viewModel.isImmersiveSpaceShown = true
            }
            .padding()
            
//            Button("Quit") {
//                viewModel.appView = AppView.WELCOME
//                viewModel.isImmersiveSpaceShown = false
//                // TODO: clean up logic
//            }
        }
    }
}

//struct VideoPreviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPreviewView()
//            .environmentObject(PlayerViewModel())
//    }
//}
