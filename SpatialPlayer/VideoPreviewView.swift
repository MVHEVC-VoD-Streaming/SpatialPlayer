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
            Button("Start", systemImage: "play.fill") {
                viewModel.isImmersiveSpaceShown = false
                viewModel.isDocumentPickerPresented = true
            }
            .padding()
            .sheet(isPresented: $viewModel.isDocumentPickerPresented) {
                DocumentPicker()
            }
            
            Button("Quit") {
                viewModel.appView = AppView.WELCOME
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
