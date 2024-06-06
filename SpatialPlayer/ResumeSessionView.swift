//
//  ResumeSessionView.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/5.
//

import SwiftUI

struct ResumeSessionView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Binding var sessionId: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var showResumeModal: Bool

    var body: some View {
        VStack {
            Text("Resume Session")
                .font(.title)
                .padding()

            TextField("Enter session ID", text: $sessionId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: handleResume) {
                Text("Resume")
                    .font(.title2)
                    .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .frame(width: 300, height: 200)
        .padding()
    }

    private func handleResume() {
        guard !sessionId.isEmpty else {
            alertMessage = "Please enter the session ID"
            showAlert = true
            return
        }

        guard let url = URL(string: "\(viewModel.serverDomain)/api/session/resume_session") else {
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = ["session_id": sessionId]

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
                let decodedData = try JSONDecoder().decode(SessionData<SessionResumeData>.self, from: data)
                
                print("\(decodedData.description)")
                
                // Dismiss the modal
                DispatchQueue.main.async {
                    showResumeModal = false
                    viewModel.sessionData = decodedData.data.session
                    viewModel.currentVideoIndex = decodedData.data.lastRatedVideoIndex + 1
                    viewModel.appView = AppView.VIDEO_PREVIEW
                }
            } catch {
                print("Failed to decode SessionResumeData \(error)")
                DispatchQueue.main.async {
                    alertMessage = "Failed to decode response"
                    showAlert = true
                }
            }
        }

        task.resume()
    }
}

struct ResumeSessoionView_Preview: PreviewProvider {
    @State static var sessionId = ""
    @State static var showAlert = false
    @State static var alertMessage = ""
    @State static var showResumeModal = false

    static var previews: some View {
        ResumeSessionView(
            sessionId: $sessionId,
            showAlert: $showAlert,
            alertMessage: $alertMessage,
            showResumeModal: $showResumeModal
        ).environmentObject(PlayerViewModel())
    }
}
