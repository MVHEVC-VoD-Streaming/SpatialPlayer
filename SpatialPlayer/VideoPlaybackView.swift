//
//  VideoPlaybackView.swift
//  SpatialPlayer
//
//  Created by Sizhe on 6/12/24.
//

import SwiftUI
import AVKit

struct VideoPlaybackView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var player: AVPlayer = AVPlayer()
    @State private var isURLSecurityScoped: Bool = false
    var videoUrl: URL
    var willPlayToStart: (() -> Void)?
    var didPlayToEnd: (() -> Void)?
    
    private func setupPlayer(with url: URL) {
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        viewModel.isVideoPlaying = true
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak playerItem] _ in
            guard playerItem != nil else { return }
            print("Video playback ended")
            
            DispatchQueue.main.async {
                viewModel.isVideoPlaying = false
                didPlayToEnd?()
                cleanupPlayer()
            }
        }
    }
    
    private func cleanupPlayer() {
        player.pause()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.replaceCurrentItem(with: nil)
        
        
        if isURLSecurityScoped, let url = viewModel.videoURL {
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    var body: some View {
        VideoPlayerView(player: $player)
            .onAppear {
                print("--- onAppear: setupPlayer")
                setupPlayer(with: videoUrl)
            }
            .onDisappear {
                print("--- onDisappear: cleanupPlayer")
                cleanupPlayer()
            }
    }
}



struct VideoPlayerView: UIViewControllerRepresentable {
    @Binding var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        print("--- makeUIViewController")
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
        return playerViewController
    }
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        print("--- updateUIViewController")
        playerViewController.player = player
    }
}

//#Preview {
//    VideoPlaybackView()
//}
