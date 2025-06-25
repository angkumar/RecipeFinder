//
//  ChatMessage.swift
//  RecipeFinder
//
//  Created by Angad Kumar on 6/25/25.
//


import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
}

struct ChatUI: View {
    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = []
    private let chatService = ChatGPTService()

    var body: some View {
        
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(12)
                                    Spacer()
                                }
                            }
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastId = messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField("Type your message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle("Chat with GPT")
    }

    private func sendMessage() {
        let userMessage = ChatMessage(isUser: true, text: inputText)
        messages.append(userMessage)
        let input = inputText
        inputText = ""

        chatService.sendMessage(input) { response in
            DispatchQueue.main.async {
                let botMessage = ChatMessage(isUser: false, text: response)
                messages.append(botMessage)
            }
        }
    }
}
