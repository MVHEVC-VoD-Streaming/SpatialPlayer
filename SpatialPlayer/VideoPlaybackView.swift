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
                guard let _playerItem = playerItem else { return }
                print("Video playback ended")
                
                DispatchQueue.main.async {
                    viewModel.isVideoPlaying = false
                    didPlayToEnd?()
                }
            }
        }
        
        private func cleanupPlayer() {
            if isURLSecurityScoped, let url = viewModel.videoURL {
                url.stopAccessingSecurityScopedResource()
            }
            player.pause()
            if player.currentItem != nil {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            }
            player.replaceCurrentItem(with: nil)
        }
        
        var body: some View {
            VideoPlayerView(player: $player)
                .onAppear {
                    setupPlayer(with: videoUrl)
                }
                .onDisappear {
                    cleanupPlayer()
                }
        }
    }



    struct VideoPlayerView: UIViewControllerRepresentable {
        @Binding var player: AVPlayer
        
        func makeUIViewController(context: Context) -> AVPlayerViewController {
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.showsPlaybackControls = false
            return playerViewController
        }
        
        func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
            playerViewController.player = player
        }
        
        func dismantleUIViewController(_ playerViewController: AVPlayerViewController, coordinator: Coordinator) {
            playerViewController.player = nil
        }
    }

//#Preview {
//    VideoPlaybackView()
//}
