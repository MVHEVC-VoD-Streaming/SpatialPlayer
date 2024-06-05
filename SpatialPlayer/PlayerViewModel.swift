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
    case VIDEO_PREVIEW = "VIDEO_PREVIEW"
    case IMMERSIVE_VIEW = "IMMERSIVE_VIEW"
    case RATING_VIEW = "RATING_VIEW"
}

class PlayerViewModel: ObservableObject {
    @Published var videoURL: URL?
    @Published var videoInfo: VideoInfo = VideoInfo()
    @Published var isImmersiveSpaceShown: Bool = false
    @Published var isVideoPlaying: Bool = false
    @Published var isDocumentPickerPresented: Bool = false
    @Published var isSpatialVideoAvailable: Bool = false
    @Published var shouldPlayInStereo: Bool = true
    @Published var appView: AppView = AppView.WELCOME
    @Published var currentVideoIndex = 0
    @Published var videoURLPlaylist: [URL] = []
    
    var isStereoEnabled: Bool {
        isSpatialVideoAvailable && shouldPlayInStereo
    }
}
