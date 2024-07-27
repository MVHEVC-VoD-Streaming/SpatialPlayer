//
//  VideoPlayerMetric.swift
//  SpatialPlayer
//
//  Created by Sizhe on 7/26/24.
//

import Foundation
import AVFoundation

// Custom error enum
enum PlayerError: Error {
    case playerNil
}


class VideoPlayerMetricMonitor {
    private var metricsCollector: MetricsCollector
    private var reportingTimer: Timer?
    private var reportingInterval: TimeInterval = 1.0
    private var player: AVPlayer
    
    init(player: AVPlayer) throws {
        self.player = player
        self.metricsCollector = try MetricsCollector(player: player)
    }
    
    func setReportingInterval(value: Float) {
        if value >= 0.0 {
            self.reportingInterval = TimeInterval(value)
        }
    }
    
    func startReporting() {
        setupEventListeners()
        
        reportingTimer = Timer.scheduledTimer(withTimeInterval: reportingInterval, repeats: true) { [weak self] _ in
            self?.sendPeriodicReport()
        }
    }
    
    private func setupEventListeners() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePlaybackStart),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        // Add more event listeners...
    }
    
    private func sendPeriodicReport() {
        Task {
            let metrics = await metricsCollector.collectMetrics()
            do {
                let results = try formatJSON(metrics)
                print(results)
            } catch {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    @objc private func handlePlaybackStart() {
        print("handlePlaybackStart")
//        let metrics = metricsCollector.collectPlaybackStartMetrics()
//        MetricsReportingService.shared.sendImmediateReport(metrics)
    }
    
    // MARK: - Cleanup Functions
    
    func stopReporting() {
        reportingTimer?.invalidate()
        reportingTimer = nil
        removeEventListeners()
    }
    
    func cleanup() {
        if reportingTimer != nil {
            stopReporting()
        }
    }
    
    private func removeEventListeners() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        cleanup()
        print("ProfessionalVideoPlayerMetrics deinitialized")
    }
}


class MetricsCollector: NSObject {
    var player: AVPlayer?
    private var timeObserverToken: Timer?
    private var logTime: Date?
    private var playbackStatus: AVPlayer.TimeControlStatus
    private var resolution: CGSize = .zero
    private var frameRate: Float = 0.0
    
    init(player: AVPlayer) throws {
        self.player = player
        self.playbackStatus = AVPlayer.TimeControlStatus.paused
        super.init()
        try setupObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    func cleanup() {
        removeObservers()
        player = nil
        timeObserverToken?.invalidate()
        timeObserverToken = nil
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.rate) {
            if let rate = change?[.newKey] as? Float {
                // playback speed rate
//                updatePlaybackStatus(rate: rate)
            }
        } else if #available(iOS 10.0, *), keyPath == #keyPath(AVPlayer.timeControlStatus) {
            // state of playback control (playing, pausing, buffering)
            if let status = change?[.newKey] as? Int,
               let timeControlStatus = AVPlayer.TimeControlStatus(rawValue: status) {
                updateTimeControlStatus(status: timeControlStatus)
            }
        }
    }
    
    private func removeObservers() {
        print("removeObservers")
        player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
    }
    
    private func setupObservers() throws {
        print("setupObservers")
        
        guard let player = self.player else {
            throw PlayerError.playerNil
        }
        
        if #available(iOS 10.0, *) {
            player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new, .initial], context: nil)
        }
    }
    
    func replacePlayer(with player: AVPlayer?) {
        self.player = player
    }
    
    func getPlayerLatestEvent() -> AVPlayerItemAccessLogEvent?  {
        guard let currentItem = player?.currentItem else { return nil }
        return currentItem.accessLog()?.events.last ?? nil
    }

//    func getResolution() async throws -> CGSize? {
//        guard let currentItem = player?.currentItem else { return nil }
//        let track = await currentItem.asset.tracks(withMediaType: .video).first
//        return try await track?.load(.naturalSize)
//    }

    func getVideoQualitySwitches() -> Int? {
        guard let currentItem = player?.currentItem else { return nil }
        return currentItem.accessLog()?.events.last?.numberOfMediaRequests
    }
    
    @available(iOS 10.0, *)
    private func updateTimeControlStatus(status: AVPlayer.TimeControlStatus) {
        playbackStatus = status
        print(formatPlaybackStatus(status))
    }
    
    func getPlaybackStatus() -> AVPlayer.TimeControlStatus {
        return self.playbackStatus
    }
    
    func getObservedBitrate(_ event: AVPlayerItemAccessLogEvent? = nil) -> Double {
        let defaultVal = 0.0
        if event != nil {
            return event?.observedBitrate ?? defaultVal
        }
        return getPlayerLatestEvent()?.observedBitrate ?? defaultVal
    }
    
    func getIndicatedBitrate(_ event: AVPlayerItemAccessLogEvent? = nil) -> Double {
        let defaultVal = 0.0
        if event != nil {
            return event?.indicatedBitrate ?? defaultVal
        }
        return getPlayerLatestEvent()?.indicatedBitrate ?? defaultVal
    }
    
    func getFrameDropped(_ event: AVPlayerItemAccessLogEvent? = nil) -> Int {
        let defaultVal = 0
        if event != nil {
            return event?.numberOfDroppedVideoFrames ?? defaultVal
        }
        return getPlayerLatestEvent()?.numberOfDroppedVideoFrames ?? defaultVal
    }
    
    private func formatPlaybackStatus(_ status: AVPlayer.TimeControlStatus) -> String {
        switch status {
        case .paused:
            return "paused"
        case .waitingToPlayAtSpecifiedRate:
            return "buffering"
        case .playing:
            return "playing"
        @unknown default:
            return "unknown"
        }
    }
    
    func getNumberOfStalls(_ event: AVPlayerItemAccessLogEvent? = nil) -> Int {
        let defaultVal = 0
        if event != nil {
            return event?.numberOfStalls ?? defaultVal
        }
        return getPlayerLatestEvent()?.numberOfStalls ?? defaultVal
    }
    
    func getTrack() async -> AVAssetTrack? {
        guard let playerItem = player?.currentItem else {
            return nil
        }
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) {
            do {
                return try await playerItem.asset.loadTracks(withMediaType: .video).first
            } catch {
                return nil
            }
        }
        return nil
    }
    
    func getPropFromTrack<T>(_ track: AVAssetTrack? = nil, prop: AVAsyncProperty<AVAssetTrack, T>, defaultValue: T) async -> T {
        do {
            let _track: AVAssetTrack?
            if let providedTrack = track {
                _track = providedTrack
            } else {
                _track = await getTrack()
            }
            
            guard let validTrack = _track else {
                throw NSError(domain: "TrackError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No valid track found"])
            }
            
            return try await validTrack.load(prop)
        } catch {
            print("Error loading property: \(error)")
            return defaultValue
        }
    }
    
    func getFrameRate(_ track: AVAssetTrack? = nil) async -> Float {
        return await getPropFromTrack(track, prop: .nominalFrameRate, defaultValue: 0.0)

    }
    
    func getCurrentResolution(_ track: AVAssetTrack? = nil) async -> CGSize {
        return await getPropFromTrack(track, prop: .naturalSize, defaultValue: .zero)
    }
    
    private func getCurrentTimestamp() -> Int64 {
          return Int64(Date().timeIntervalSince1970 * 1000)
      }
    
    func formatTimestamp(_ timestamp: Int64) -> String {
        return (timestamp * 1000).formatted()
    }
    
    func collectMetrics() async -> [String: String] {
        let event = getPlayerLatestEvent()
        let playbackStartDate = event?.playbackStartDate ?? nil
        let track = await getTrack()
        self.frameRate = await getFrameRate(track)
        self.resolution = await getCurrentResolution(track)
        return [
            "timestamp": formatTimestamp(getCurrentTimestamp()),
            "playbackStartDate": formatTimestamp(Int64(playbackStartDate?.timeIntervalSince1970 ?? 0.0)),
            "playbackStatus": formatPlaybackStatus(getPlaybackStatus()),
            "observedBitrateBps": formatBitrate(getObservedBitrate(event), unit: "bps"),
            "indicatedBitrateBps": formatBitrate(getIndicatedBitrate(event), unit: "bps"),
            "frameDropped": getFrameDropped().formatted(),
            "stalls": getNumberOfStalls().formatted(),
            "frameRate": self.frameRate.formatted(),
            "resolution": self.resolution.debugDescription,
        ]
    }
}


struct ComprehensiveMetrics {
    let timestamp: Int64
    let bitrate: Double
    let resolution: CGSize
    let frameRate: Double
    let bufferHealth: Double
    let timeToFirstFrame: TimeInterval
    let droppedFrames: Int
//    let audioVideoSyncIssues: [AudioVideoSyncIssue]
//    let cdnPerformance: CDNPerformanceMetrics
//    let errorRates: ErrorRateMetrics
}
