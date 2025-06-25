//
//  ChatGPTService.swift
//  RecipeFinder
//
//  Created by Angad Kumar on 6/25/25.
//

import Foundation

class ChatGPTService {
    private let apiKey = "Give me api Key dumbass" // Replace this

    func sendMessage(_ message: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4", // or "gpt-3.5-turbo"
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
                completion("⚠️ Failed to parse response.")
            }
        }.resume()
    }
}
