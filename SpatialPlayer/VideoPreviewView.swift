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
    weak var replayDelegate: ReplayViewDelegate?
    @State private var player: AVPlayer = AVPlayer()
    @State private var isURLSecurityScoped: Bool = false
    @State private var coverData: CoverData?
    
    
    var currentVideoURL: URL? {
//        return URL(string: "\(viewModel.serverDomain)/video/driving/vp-2200x2200.MOV")
//        return URL(string: "\(viewModel.serverDomain)/video/user_study/driving/driving@2160x2160-30M.mov")
        if let sessionData = viewModel.sessionData {
            let item = sessionData.playlist[viewModel.currentVideoIndex]
            
            return URL(string: "\(viewModel.serverDomain)\(item.url)")
        }
        return nil
    }
    
    private func setupPlayer(with url: URL) {
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        viewModel.isVideoPlaying = true
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak playerItem] _ in
            print("Video playback ended")
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            DispatchQueue.main.async {
//                viewModel.isImmersiveSpaceShown = false
                viewModel.isVideoPlaying = false
                viewModel.currentVideoIndex += 1
                coverData = nil
//                if viewModel.isTutorial {
//                    viewModel.appView = AppView.TUTORIAL
//                } else {
//                    viewModel.ratingVideoIndex = viewModel.currentVideoIndex
//                    viewModel.appView = AppView.RATING_VIEW
//                }
            }
        }
    }
    
    private func cleanupPlayer() {
        if isURLSecurityScoped, let url = viewModel.videoURL {
            url.stopAccessingSecurityScopedResource()
        }
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
    
    func didDismiss() {
        // Handle the dismissing action.
    }
    
    
    var body: some View {
        VStack {
            Text("Current Video: \(viewModel.currentVideoIndex + 1) / \(viewModel.playlist.count)").bold()

            
            Button("Play", systemImage: "play.fill") {
                guard let videoURL = currentVideoURL else {
                    print("No video URL selected")
                    return
                }
                coverData = CoverData(url: videoURL)
                //                viewModel.appView = AppView.IMMERSIVE_VIEW
                viewModel.videoURL = videoURL
                //                viewModel.isImmersiveSpaceShown = true
            }
            .padding()
            .fullScreenCover(item: $coverData,
                             onDismiss: didDismiss) { details in
                VStack(spacing: 20) {
                    VideoPlayerView(url: details.url, player: $player)
                        .onAppear {
                            setupPlayer(with: details.url)
                        }
                        .onDisappear {
                            cleanupPlayer()
                        }
//                    if let url = details.url {
//
//                    }
                }
                .onTapGesture {
                    coverData = nil
                }
            }
            
            //            Button("Quit") {
            //                viewModel.appView = AppView.WELCOME
            //                viewModel.isImmersiveSpaceShown = false
            //                // TODO: clean up logic
            //            }
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    var url: URL
    @Binding var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        playerViewController.player = player
    }
}


struct VideoPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPreviewView()
            .environmentObject(PlayerViewModel())
    }
}
