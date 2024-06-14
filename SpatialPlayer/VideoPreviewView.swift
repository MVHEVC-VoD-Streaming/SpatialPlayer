//
//  VideoPreviewView.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/4.
//

import SwiftUI
import AVKit

struct CoverData: Identifiable {
    var id: String {
        return "1"
    }
    let url: URL
}

struct VideoPreviewView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var coverData: CoverData?
    
    func didDismiss() {
        // Handle the dismissing action.
    }
    
    func didPlayToEnd() {
        coverData = nil
        viewModel.ratingVideoIndex = viewModel.currentVideoIndex
        viewModel.appView = AppView.RATING_VIEW
    }
    
    
    var body: some View {
        VStack {
            Text("Current Video: \(viewModel.currentVideoIndex + 1) / \(viewModel.playlist.count)").bold()

            
            Button("Play", systemImage: "play.fill") {
                guard let videoURL = viewModel.currentVideoURL else {
                    print("No video URL selected")
                    return
                }
                viewModel.videoURL = videoURL
                coverData = CoverData(url: videoURL)
            }
            .padding()
            .fullScreenCover(item: $coverData,
                             onDismiss: didDismiss) { details in
                VStack(spacing: 20) {
                    VideoPlaybackView(
                        videoUrl: details.url,
                        didPlayToEnd: didPlayToEnd
                    )
                }
                .onTapGesture {
                    coverData = nil
                }
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
