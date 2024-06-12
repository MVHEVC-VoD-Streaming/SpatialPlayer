//
//  TutorialView.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/4.
//

import SwiftUI
import QuickLook

struct TutorialView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var coverData: CoverData?
    
    var currentVideoURL: URL? {
        if !viewModel.isTutorialPlayBestQuality && viewModel.shouldPlayInStereo {
            return URL(string: "\(viewModel.serverDomain)/video/user_study_edu/kitchen/kitchen@480x480-1M.mov")
        }
        if !viewModel.isTutorialPlayBestQuality && !viewModel.shouldPlayInStereo {
            return URL(string: "\(viewModel.serverDomain)/video/user_study_edu/kitchen/kitchen@480x480-1M.left.mov")
        }
        if viewModel.isTutorialPlayBestQuality && !viewModel.shouldPlayInStereo {
            return URL(string: "\(viewModel.serverDomain)/video/user_study_edu/kitchen/kitchen@2160x2160-30M.left.mov")
        }
        return URL(string: "\(viewModel.serverDomain)/video/user_study_edu/kitchen/kitchen@2160x2160-30M.mov")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tutorial for User Study")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            Text("Spatial video is a new way to record and view your videos in 3D. This tutorial will help you understand the difference between mono and spatial videos.")
                .padding(.bottom, 10)
            
            Text("You can switch the stereoscopic effect as well as the video quality on and off using the switches below. Play the demo video with the selected stereo settings. When you're done, click the Finish button to return to the home screen.")
                .padding(.bottom, 20)
            
            
            Toggle(isOn: $viewModel.shouldPlayInStereo) {
                Text(viewModel.shouldPlayInStereo ? "Stereo Mode: On" : "Stereo Mode: Off")
            }
            
            Toggle(isOn: $viewModel.isTutorialPlayBestQuality) {
                Text(viewModel.isTutorialPlayBestQuality ? "Quality: Best" : "Quality: Worst")
            }
            
            HStack(content: {
                Button(action: playDemoVideo) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play Demo")
                    }
                    .font(.title2)
                }
                .fullScreenCover(item: $coverData,
                                 onDismiss: didDismiss) { details in
                    VStack(spacing: 20) {
                        VideoPlaybackView(
                            videoUrl: details.url,
                            didPlayToEnd: didPlayToEnd
                        )
                    }
                    .onTapGesture {
                        coverData = nil
                    }
                }
                
                Spacer()
                Button(action: finishTutorial) {
                    Text("Finish")
                        .font(.title2)
                }
            }
            )
            .padding(.top)
            .padding(.bottom)
            .frame(maxWidth: .infinity)
        }
        .frame(width: 400)
    }
    
    
    private func didDismiss() {
        // Handle the dismissing action.
    }
    
    private func didPlayToEnd() {
        coverData = nil
    }

    
    private func playDemoVideo() {
        guard let videoURL = currentVideoURL else {
            print("No video URL selected")
            return
        }
        
        viewModel.videoURL = videoURL
        viewModel.isTutorial = true
        coverData = CoverData(url: videoURL)

    }
    
    private func finishTutorial() {
        // Logic to finish the tutorial and go back to home screen
        viewModel.appView = AppView.WELCOME
        viewModel.videoURL = nil
        viewModel.isImmersiveSpaceShown = false
        viewModel.isTutorial = false
    }
}

//struct TutorialView_Previews: PreviewProvider {
//    static var previews: some View {
//        TutorialView()
//            .environmentObject(PlayerViewModel())
//    }
//}
