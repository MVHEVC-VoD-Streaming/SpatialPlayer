//
//  ImmersiveView.swift
//  SpatialPlayer
//
//  Created by Michael Swanson on 2/6/24.
//

import AVKit
import RealityKit
import SwiftUI
import UniformTypeIdentifiers

//struct ImmersiveView: View {
//    @EnvironmentObject var viewModel: PlayerViewModel
//    @State private var player: AVPlayer = AVPlayer()
//    @State private var isURLSecurityScoped: Bool = false
//    @State private var videoMaterial: VideoMaterial?
//    @Environment(\.openWindow) var openWindow
//    
//    var body: some View {
//        RealityView { content in
//            guard let url = viewModel.videoURL else {
//                print("No video URL selected")
//                return
//            }
//            //            let url = URL(string: "http://192.168.100.160:5000/video/library_vp/vp/multivariant.m3u8")!
//            ////            let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/historic_planet_content_2023-10-26-3d-video/main.m3u8")!
//            //
//            // Wrap access in a security scope
//            //            isURLSecurityScoped = url.startAccessingSecurityScopedResource()
//            
//            let asset = AVURLAsset(url: url)
//            let playerItem = AVPlayerItem(asset: asset)
//            
//            //            guard let videoInfo = await VideoTools.getVideoInfo(asset: asset) else {
//            //                print("Failed to get video info")
//            //                return
//            //            }
//            
//            // TODO: For HLS video info, how do we get from the track?
//            let videoInfo = VideoInfo()
//            videoInfo.isSpatial = false
//            if viewModel.isTutorial {
//                // Hard code the isSpatialVideoAvailable for demo video
//                videoInfo.isSpatial = true
//            }
//            if let videoType = viewModel.currentVideo?.type {
//                if videoType == "stereo" {
//                    videoInfo.isSpatial = true
//                }
//            }
//            videoInfo.size = CGSize(width: 2200, height: 2200)
//            videoInfo.projectionType = CMProjectionType.rectangular
//            videoInfo.horizontalFieldOfView = 71.59
//            
//            // NOTE: If you want to force a custom projection, horizontal field of view, etc. because
//            // your media doesn't contain the correct metadata, you can do that here. For example:
//            //
//            // videoInfo.projectionType = .equirectangular
//            // videoInfo.horizontalFieldOfView = 360.0
//            
//            viewModel.videoInfo = videoInfo
//            viewModel.isSpatialVideoAvailable = videoInfo.isSpatial
//            
//            guard let (mesh, transform) = await VideoTools.makeVideoMesh(videoInfo: videoInfo) else {
//                print("Failed to get video mesh")
//                return
//            }
//            
//            // wrap logical player with UI interface
//            videoMaterial = VideoMaterial(avPlayer: player)
//            guard let videoMaterial else {
//                print("Failed to create video material")
//                return
//            }
//            
//            updateStereoMode()
//            let videoEntity = Entity()
//            videoEntity.components.set(ModelComponent(mesh: mesh, materials: [videoMaterial]))
//            videoEntity.transform = transform
//            content.add(videoEntity)
//            
//            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak playerItem] _ in
//                print("Video playback ended")
//                
//                NotificationCenter.default.removeObserver(
//                    self,
//                    name: .AVPlayerItemDidPlayToEndTime,
//                    object: playerItem
//                )
//                
//                // Ensure the update happens in main thread
//                DispatchQueue.main.async {
//                    viewModel.isImmersiveSpaceShown = false
//                    viewModel.isVideoPlaying = false
//                    if viewModel.isTutorial {
//                        viewModel.appView = AppView.TUTORIAL
//                    } else {
//                        viewModel.ratingVideoIndex = viewModel.currentVideoIndex
//                        viewModel.appView = AppView.RATING_VIEW
//                    }
//                }
//            }
//            
//            player.replaceCurrentItem(with: playerItem)
//            player.play()
//            viewModel.isVideoPlaying = true
//        }
//        .onDisappear {
//            if isURLSecurityScoped, let url = viewModel.videoURL {
//                url.stopAccessingSecurityScopedResource()
//            }
//            player.pause()
//            player.replaceCurrentItem(with: nil)
//        }
//        .onChange(of: viewModel.shouldPlayInStereo) { _, newValue in
//            updateStereoMode()
//        }
//    }
//    
//    func updateStereoMode() {
//        if let videoMaterial {
//            videoMaterial.controller.preferredViewingMode =
//            viewModel.isStereoEnabled ? .stereo : .mono
//        }
//        print("viewModel.isStereoEnabled: \(viewModel.isStereoEnabled)")
//    }
//}

struct ImmersiveView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var player: AVPlayer = AVPlayer()
    @State private var isURLSecurityScoped: Bool = false
    @State private var videoMaterial: VideoMaterial?
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        VStack {
            if let url = viewModel.videoURL {
                VideoPlayerView(url: url, player: $player)
                    .onAppear {
                        setupPlayer(with: url)
                    }
                    .onDisappear {
                        cleanupPlayer()
                    }
            } else {
                Text("No video URL selected")
            }
        }
        .onChange(of: viewModel.shouldPlayInStereo) { _, newValue in
            updateStereoMode()
        }
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
                viewModel.isImmersiveSpaceShown = false
                viewModel.isVideoPlaying = false
                if viewModel.isTutorial {
                    viewModel.appView = AppView.TUTORIAL
                } else {
                    viewModel.ratingVideoIndex = viewModel.currentVideoIndex
                    viewModel.appView = AppView.RATING_VIEW
                }
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
    
    private func updateStereoMode() {
        print("viewModel.isStereoEnabled: \(viewModel.isStereoEnabled)")
    }
}

//struct VideoPlayerView: UIViewControllerRepresentable {
//    var url: URL
//    @Binding var player: AVPlayer
//    
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        return playerViewController
//    }
//    
//    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
//        playerViewController.player = player
//    }
//}
