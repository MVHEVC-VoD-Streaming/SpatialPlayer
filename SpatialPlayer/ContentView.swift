//
//  ContentView.swift
//  SpatialPlayer
//
//  Created by Michael Swanson on 2/6/24.
//

import SwiftUI

protocol ReplayViewDelegate: AnyObject {
    func didReplay()
}

struct ContentView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    weak var replayDelegate: ReplayViewDelegate?
    
    var body: some View {
        VStack {
            if viewModel.isImmersiveSpaceShown {
                Text("Spatial:").bold() + Text(" \(viewModel.videoInfo.isSpatial ? "Yes" : "No")")
                Text("Size:").bold() + Text(" \(viewModel.videoInfo.sizeString)")
                Text("Projection:").bold() + Text(" \(viewModel.videoInfo.projectionTypeString)")
                Text("Horizontal FOV:").bold() + Text(" \(viewModel.videoInfo.horizontalFieldOfViewString)")
                Toggle("Show in stereo", isOn: $viewModel.shouldPlayInStereo)
                    .fixedSize()
                    .disabled(!viewModel.isSpatialVideoAvailable)
                    .padding()
                Button("Replay") {
                    replayDelegate?.didReplay()
                }
            } else {
                Text("User Study on Spatial Video Experience").font(.title)
                Text("by NU XR Lab").padding(.bottom)
                
                Text("Welcome! This study compares video formats.")
                Text("You will watch 40 short video clips and rate each one.").padding(.bottom)
                
                VStack(alignment: .leading, content: {
                    Text("Steps:")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    
                    Text("1. Watch Videos: 40 clips, 15 seconds each.")
                        .padding(.bottom, 5)
                    
                    Text("2. Rate Each Video:")
                        .padding(.bottom, 5)
        
                    Text("- Video Quality: 1 (Bad) to 5 (Excellent)")
                        
                    Text("- Depth Quality: 1 (No Depth) to 5 (Excellent)")
                
                    Text("- Overall Experience: 1 (Bad) to 5 (Excellent)")
                })
            }
            Button("Start", systemImage: "play.fill") {
                viewModel.isImmersiveSpaceShown = false
                viewModel.isDocumentPickerPresented = true
            }
            .padding()
            .sheet(isPresented: $viewModel.isDocumentPickerPresented) {
                DocumentPicker()
            }
        }
        .controlSize(.large)
        .onChange(of: viewModel.isImmersiveSpaceShown) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "PlayerImmersiveSpace") {
                    case .opened:
                        viewModel.isImmersiveSpaceShown = true
                    default:
                        viewModel.isImmersiveSpaceShown = false
                    }
                } else {
                    await dismissImmersiveSpace()
                    viewModel.isImmersiveSpaceShown = false
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PlayerViewModel())
    }
}
