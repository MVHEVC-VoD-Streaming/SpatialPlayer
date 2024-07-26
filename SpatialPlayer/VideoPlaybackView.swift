//
//  VideoPlaybackView.swift
//  SpatialPlayer
//
//  Created by Sizhe on 6/12/24.
//

import SwiftUI
import AVKit

func formatBitrate(bitrate: Double) -> String {
    let mbps = bitrate / 1_000_000.0
    if mbps >= 1.0 {
        return String(format: "%.2f Mbps", mbps)
    } else {
        let kbps = bitrate / 1_000.0
        return String(format: "%.2f Kbps", kbps)
    }
}

class PlayerObserver: NSObject {
    private var player: AVPlayer
    private var timeObserverToken: Any?
    private var monitor: VideoPlayerMetricMonitor
    
    init(player: AVPlayer) {
        self.player = player
        self.monitor = VideoPlayerMetricMonitor(player: player)
        super.init()
        setupObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    private func setupObservers() {
        // We'll add our observers here
        print("setupObservers")
        
        // Observe rate changes
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new, .initial], context: nil)
        
        // Add periodic time observer
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updatePlaybackTime(time)
            let bitrate = self?.monitor.getBitrate()
            guard bitrate != nil else {
                print("bitrate is nil")
                return
            }
            print("bitrate: \(formatBitrate(bitrate: bitrate!))")
//            let videoQualitySwithc = self?.monitor.getVideoQualitySwitches()
            
        }
    }
    
    private func removeObservers() {
        // We'll remove our observers here
        print("removeObservers")
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
    }
    
    private func updatePlaybackStatus(rate: Float) {
        if rate == 0 {
            print("Player is paused")
        } else {
            print("Player is playing at rate: \(rate)")
        }
    }
    
    @available(iOS 10.0, *)
    private func updateTimeControlStatus(status: AVPlayer.TimeControlStatus) {
        switch status {
        case .paused:
            print("Player is paused")
        case .waitingToPlayAtSpecifiedRate:
            print("Player is buffering")
        case .playing:
            print("Player is playing")
        @unknown default:
            print("Unknown playback status")
        }
    }

    private func updatePlaybackTime(_ time: CMTime) {
        let seconds = CMTimeGetSeconds(time)
        print("Current playback time: \(seconds) seconds")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.rate) {
            if let rate = change?[.newKey] as? Float {
                updatePlaybackStatus(rate: rate)
            }
        }
    }

}


struct VideoPlaybackView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var player: AVPlayer = AVPlayer()
    @State private var isURLSecurityScoped: Bool = false
    @State private var playbackMetricMonitor: VideoPlayerMetricMonitor?
    @State private var playerObserver: PlayerObserver?
    @State private var playbackMetricsTimer: Timer?

    var videoUrl: URL
    var willPlayToStart: (() -> Void)?
    var didPlayToEnd: (() -> Void)?
    
    private func setupPlayer(with url: URL) {
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        playerObserver = PlayerObserver(player: player)
        
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
        playbackMetricMonitor?.replacePlayer(with: nil)
        playerObserver = nil
        
        
        if isURLSecurityScoped, let url = viewModel.videoURL {
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    // Playback Metrics Recording
    private func startRecordingPlaybackMetrics() {
        print("startRecordingPlaybackMetrics ...")

        playbackMetricsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            print("logging playbackMetrics ...")
//            guard let bitrate = getBitrate(), let resolution = getResolution() else { return }
//            print("Bitrate: \(bitrate), Resolution: \(resolution.width)x\(resolution.height)")
            // Add more metrics logging as needed
        }
    }

    private func stopRecordingPlaybackMetrics() {
        print("stop logging playbackMetrics ...")
        playbackMetricsTimer?.invalidate()
        playbackMetricsTimer = nil
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
