//
//  TutorialView.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/4.
//

import SwiftUI

struct TutorialView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var currentVideoURL: URL? {
        return URL(string: "\(viewModel.serverDomain)/video/user_study_edu/tellurion.mov")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tutorial for User Study")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            Text("Spatial video is a new way to record and view your videos in 3D. This tutorial will help you understand the difference between mono and spatial videos.")
                .padding(.bottom, 10)
            
            Text("You can switch the stereoscopic effect on and off using the switch below. Play the demo video with the selected stereo settings. When you're done, click the Finish button to return to the home screen.")
                .padding(.bottom, 20)
            
            Toggle(isOn: $viewModel.shouldPlayInStereo) {
                Text(viewModel.shouldPlayInStereo ? "Stereo Mode: On" : "Stereo Mode: Off")
            }
            .frame(width: 200)
            .padding()
            
            HStack {
                Button(action: playDemoVideo) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play Demo")
                    }
                    .font(.title2)
                }
                Spacer()
                Button(action: finishTutorial) {
                    Text("Finish")
                        .font(.title2)
                }
            }
        }
        .frame(width: 400)
    }
    
    private func playDemoVideo() {
        guard let videoURL = currentVideoURL else {
            print("No video URL selected")
            return
        }
        viewModel.appView = AppView.IMMERSIVE_VIEW
        viewModel.videoURL = videoURL
        viewModel.isImmersiveSpaceShown = true
        viewModel.isTutorial = true
    }
    
    private func finishTutorial() {
        // Logic to finish the tutorial and go back to home screen
        viewModel.appView = AppView.WELCOME
        viewModel.videoURL = nil
        viewModel.isImmersiveSpaceShown = false
        viewModel.isTutorial = false
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
            .environmentObject(PlayerViewModel())
    }
}
