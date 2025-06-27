//
//  ChatMessage.swift
//  RecipeFinder
//
//  Created by Angad Kumar on 6/25/25.
//

import SwiftUI
import PhotosUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
    let image: UIImage?

    init(isUser: Bool, text: String, image: UIImage? = nil) {
        self.isUser = isUser
        self.text = text
        self.image = image
    }
}

struct ChatUI: View {
    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    
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
                                    VStack(alignment: .trailing) {
                                        if let image = message.image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: 200)
                                                .cornerRadius(8)
                                        }
                                        Text(message.text)
                                            .padding()
                                            .background(Color.blue.opacity(0.8))
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                } else {
                                    VStack(alignment: .leading) {
                                        if let image = message.image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: 200)
                                                .cornerRadius(8)
                                        }
                                        Text(message.text)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(12)
                                    }
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
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .padding(8)
                }
                
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                sendImage(image)
                selectedImage = nil
            }
        }
    }

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
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
    
    private func sendImage(_ image: UIImage) {
        let userMessage = ChatMessage(isUser: true, text: "📷 Sent an image", image: image)
        messages.append(userMessage)

        chatService.analyzeImage(image) { response in
            DispatchQueue.main.async {
                let botMessage = ChatMessage(isUser: false, text: response)
                messages.append(botMessage)
            }
        }
    }
}
