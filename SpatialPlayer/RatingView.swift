//
//  RatingView.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/5.
//
import SwiftUI
import RealityKit

struct StarRatingView: View {
    @Binding var rating: Int?
    var maxRating: Int = 5
    var starSize: CGFloat = 60 // Adjust the size of the stars

    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= (rating ?? 0) ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(star <= (rating ?? 0) ? .yellow : .gray)
                    .onTapGesture {
                        rating = star
                    }
                    .hoverEffect(.automatic)
            }
        }
    }
}

struct RatingView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Environment(\.presentationMode) private var presentationManager
    
    @State private var videoQuality: Int?
    @State private var depthQuality: Int?
    @State private var overallExperience: Int?
    @State private var showAlert = false
    @State private var alertMessage = ""

    var currentVideoId: String? {
        if let sessionData = viewModel.sessionData {
            let item = sessionData.playlist[viewModel.currentVideoIndex]
            return item.id
        }
        return nil
    }

    var body: some View {
        VStack {
            Text("Please rate this video").font(.title)
            Text("Current Video: \(viewModel.ratingVideoIndex + 1) / \(viewModel.playlist.count)").bold()
            
            VStack(alignment: .leading, spacing: 20) {
                Section(header: Text("Video Quality: How clear and sharp is the video?")) {
                    StarRatingView(rating: $videoQuality)
                }
                
                Section(header: Text("Depth Quality: How well do you perceive the depth in the video?")) {
                    StarRatingView(rating: $depthQuality)
                }
                
                Section(header: Text("Overall Experience: Your general impression of the video")) {
                    StarRatingView(rating: $overallExperience)
                }
            }.padding()
            
            HStack {
                Button(action: handleReplay) {
                    HStack {
                        Text("Replay")
                    }
                }
                Spacer()
                Button(action: handleNext) {
                    Image(systemName: "play.fill")
                    Text("Next")
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }.frame(maxWidth: .infinity)
                .padding(.top, 40)
        }
        .frame(width: 450)
    }
    
    private func handleReplay() {
        viewModel.currentVideoIndex = viewModel.ratingVideoIndex
        viewModel.appView = AppView.IMMERSIVE_VIEW
        viewModel.isImmersiveSpaceShown = true
    }

    private func handleNext() {
        guard let videoQuality = videoQuality,
              let depthQuality = depthQuality,
              let overallExperience = overallExperience,
              let videoId = currentVideoId else {
            alertMessage = "Please complete all ratings before proceeding."
            showAlert = true
            return
        }

        guard let sessionId = viewModel.sessionData?.id else {
            alertMessage = "Failed to get session id"
            showAlert = true
            return
        }

        let scores: [String: [String: Int]] = [
            videoId: [
                "videoQuality": videoQuality,
                "depthQuality": depthQuality,
                "overallQoe": overallExperience
            ]
        ]

        let requestBody: [String: Any] = [
            "session_id": sessionId,
            "update_mode": "append",
            "scores": scores
        ]

        guard let url = URL(string: "\(viewModel.serverDomain)/api/session/update_session") else {
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            alertMessage = "Failed to serialize request body"
            showAlert = true
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Failed to submit data: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "No response data received"
                    showAlert = true
                }
                return
            }

            do {
                // Handle response if needed
                let responseObject = try JSONSerialization.jsonObject(with: data, options: [])
                print("Response: \(responseObject)")
                
                // Proceed to next video
                DispatchQueue.main.async {
                    if viewModel.hasNextVideo {
                        viewModel.currentVideoIndex += 1
                        viewModel.appView = AppView.VIDEO_PREVIEW
                    } else {
                        viewModel.appView = AppView.ENDING_VIEW
                        print("Test complete, route to ending view")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Failed to decode response"
                    showAlert = true
                }
            }
        }

        task.resume()
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        RatingView().environmentObject(PlayerViewModel())
            .frame(width: 400, height: 300)
    }
}

