//
//  WelcomeView.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/4.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: PlayerViewModel

    var body: some View {
        VStack {
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
            
            Button("Start", systemImage: "play.fill") {
                viewModel.isDocumentPickerPresented = true
            }
            .padding()
            .sheet(isPresented: $viewModel.isDocumentPickerPresented) {
                DocumentPicker()
            }
        }
    }
}

//struct WelcomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        WelcomeView()
//            .environmentObject(PlayerViewModel())
//    }
//}
