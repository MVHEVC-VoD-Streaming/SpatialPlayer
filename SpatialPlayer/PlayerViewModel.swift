//
//  PlayerViewModel.swift
//  SpatialPlayer
//
//  Created by Michael Swanson on 2/6/24.
//

import Combine
import Foundation

enum AppView: String {
    case WELCOME = "WELCOME"
    case TUTORIAL = "TUTORIAL"
    case VIDEO_PREVIEW = "VIDEO_PREVIEW"
    case IMMERSIVE_VIEW = "IMMERSIVE_VIEW"
    case RATING_VIEW = "RATING_VIEW"
    case ENDING_VIEW = "ENDING_VIEW"
}

class PlayerViewModel: ObservableObject {
    @Published var videoURL: URL?
    @Published var videoInfo: VideoInfo = VideoInfo()
    @Published var isImmersiveSpaceShown: Bool = false
    @Published var isVideoPlaying: Bool = false
    @Published var isTutorial: Bool = false
    @Published var isTutorialPlayBestQuality = true
    @Published var isDocumentPickerPresented: Bool = false
    @Published var isSpatialVideoAvailable: Bool = false
    @Published var shouldPlayInStereo: Bool = true
    @Published var appView: AppView = AppView.WELCOME
    @Published var currentVideoIndex = 0
    @Published var ratingVideoIndex = 0
    @Published var videoURLPlaylist: [URL] = []
    @Published var sessionData: SessionDetails?
//    @Published var serverDomain: String = "http://192.168.1.215:3000"
    @Published var serverDomain: String = "http://192.168.100.160:3000"
//    @Published var serverDomain: String = "http://10.0.0.184:3000"
    
    var isStereoEnabled: Bool {
        isSpatialVideoAvailable && shouldPlayInStereo
    }
    
    var playlist: [PlaylistItem] {
        if let sessionData = self.sessionData {
            return sessionData.playlist
        }
        return []
    }
    
    var currentVideo: PlaylistItem? {
        if self.currentVideoIndex >= 0 && self.currentVideoIndex < self.playlist.count {
            return self.playlist[self.currentVideoIndex]
        }
        return nil
    }
    
    var hasNextVideo: Bool {
        if self.playlist.count == 0 {
            return false
        }
        let nextIndex = self.currentVideoIndex + 1
        return nextIndex >= 0 && nextIndex < self.playlist.count
    }
}
