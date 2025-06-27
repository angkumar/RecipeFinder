//
//  ChatGPTService.swift
//  RecipeFinder
//
//  Created by Angad Kumar on 6/25/25.
//

import Foundation
import UIKit

class ChatGPTService {
    private let apiKey = "" // Replace this

    func sendMessage(_ message: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": message]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("⚠️ Error: \(error?.localizedDescription ?? "Unknown")")
                return
            }

            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = result["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("⚠️ Raw API response:\n\(jsonString)")
                }
                completion("⚠️ Failed to parse response.")
            }
        }.resume()
    }

    func analyzeImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard !apiKey.isEmpty else {
            completion("API key is missing")
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion("Failed to convert image to data")
            return
        }

        // Note: Currently OpenAI requires special handling for image uploads.
        // As of now, to analyze images with GPT-4 vision, you usually send
        // a multipart/form-data POST with image + prompt to the vision-enabled chat endpoint.
        // This example is simplified and may require adjustments when the API supports images directly.

        // For demonstration, we will call the chat completions endpoint with base64-encoded image.

        let base64Image = imageData.base64EncodedString()
        let prompt = "Describe the content of this image: data:image/jpeg;base64,\(base64Image)"

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini", // or "gpt-4" if you have access
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion("Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                completion("No data in response")
                return
            }
            if let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = responseJSON["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
            } else if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let errorDict = errorJSON["error"] as? [String: Any],
                      let message = errorDict["message"] as? String {
                completion("Error from API: \(message)")
            } else {
                completion("Failed to parse response.")
            }
        }.resume()
    }
}
