//
//  WelcomeView.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/4.
//

import SwiftUI

struct EndingView: View {
    @EnvironmentObject var viewModel: PlayerViewModel

    var body: some View {
        VStack {
            Text("User Study on Spatial Video Experience").font(.title)
            Text("by NU XR Lab").padding(.bottom)
            
            Text("The user study is now complete. Thank you for your participation").padding()
            
            Button("Return to Home", systemImage: "home.fill") {
                viewModel.appView = AppView.WELCOME
                // Reset variable
                viewModel.isImmersiveSpaceShown = false
                viewModel.videoURL = nil
                viewModel.currentVideoIndex = 0
                viewModel.sessionData = nil
            }
            .padding()
//            .sheet(isPresented: $viewModel.isDocumentPickerPresented) {
//                DocumentPicker()
//            }
        }
    }
}

struct EndingView_Previews: PreviewProvider {
    static var previews: some View {
        EndingView()
            .environmentObject(PlayerViewModel())
    }
}
