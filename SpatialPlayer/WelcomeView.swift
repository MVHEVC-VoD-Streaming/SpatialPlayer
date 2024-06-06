//
//  WelcomeView.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/4.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var showResumeModal = false
    @State private var sessionId: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .center, content: {
            VStack(alignment: .center, content: {
                Text("User Study on Spatial Video Experience").font(.title)
                Text("by Spatial Internet Research Group").padding(.bottom)
            })
            
            VStack(alignment: .leading, content: {
                Text("Welcome! This study aims to compare viewing experience with mono and stereo videos across different quality levels on Vision Pro.")
                
                Text("You will watch 40 short video clips and rate each one.").padding(.bottom)
                
                Text("Steps:")
                    .padding(.bottom, 5)
                
                Text("1. Watch Videos: 40 clips, 15 seconds each.")
                    .padding(.bottom, 5)
                
                Text("2. Rate Each Video:")
                    .padding(.bottom, 5)
                
                Text("- Video Quality: 1 (Bad) to 5 (Excellent)")
                
                Text("- Depth Quality: 1 (No Depth) to 5 (Excellent)")
                
                Text("- Overall Experience: 1 (Bad) to 5 (Excellent)")
            })
                .padding()
            
            HStack {
                Button(action: {
                       showResumeModal = true
                   }) {
                       Text("or Resume a session")
                   }
                   .sheet(isPresented: $showResumeModal, content: {
                       ResumeSessionView(
                          sessionId: $sessionId,
                          showAlert: $showAlert,
                          alertMessage: $alertMessage,
                          showResumeModal: $showResumeModal
                      )
                   })
                
                
                Button("Start", systemImage: "play.fill") {
    //                viewModel.isDocumentPickerPresented = true
                    fetchSessionData()
                }
            }.padding(.top)
        }).frame(width: 450)
    }
    
    private func fetchSessionData() {
        guard let url = URL(string: "\(viewModel.serverDomain)/api/session/create_session") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData: [String: Any] = [:]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: [])
        } catch {
            print("Failed to serialize request data: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching session data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(SessionData<SessionDetails>.self, from: data)
                DispatchQueue.main.async {
                    viewModel.sessionData = decodedData.data
                    viewModel.appView = AppView.VIDEO_PREVIEW
                }
                print("Decode data successfully")
            } catch {
                print("Failed to decode JSON response: \(error)")
            }
        }

        task.resume()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(PlayerViewModel())
    }
}
