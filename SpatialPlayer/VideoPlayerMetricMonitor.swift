//
//  VideoPlayerMetric.swift
//  SpatialPlayer
//
//  Created by Sizhe on 7/26/24.
//

import Foundation
import AVFoundation

class VideoPlayerMetricMonitor: NSObject {
    var player: AVPlayer?
    
    init(player: AVPlayer? = nil) {
        self.player = player
    }
    
    func replacePlayer(with player: AVPlayer?) {
        self.player = player
    }

    func getBitrate() -> Double? {
        guard let currentItem = player?.currentItem else { return nil }
        return currentItem.accessLog()?.events.last?.indicatedBitrate
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
}
