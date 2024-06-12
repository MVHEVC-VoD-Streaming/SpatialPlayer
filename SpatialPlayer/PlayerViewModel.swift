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
    @Published var sessionData: SessionDetails?
    @Published var serverDomain: String = "http://192.168.100.242:3000"
//    @Published var serverDomain: String = "http://192.168.1.215:3000"
//    @Published var serverDomain: String = "http://192.168.100.160:3000"
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
    
    
    var currentVideoURL: URL? {
//        return URL(string: "\(viewModel.serverDomain)/video/driving/vp-2200x2200.MOV")
//        return URL(string: "\(viewModel.serverDomain)/video/user_study/driving/driving@2160x2160-30M.mov")
        if let sessionData = self.sessionData {
            let item = sessionData.playlist[self.currentVideoIndex]
            
            return URL(string: "\(self.serverDomain)\(item.url)")
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
    
    func reset() {
        self.videoURL = nil
        self.appView = AppView.WELCOME
        self.currentVideoIndex = 0
        self.ratingVideoIndex = 0
        self.sessionData = nil
    }
}
