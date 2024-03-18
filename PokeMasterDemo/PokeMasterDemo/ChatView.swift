//
//  ChatView.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2024/3/18.
//

import SwiftUI
import Combine

struct ChatView: View {
    @State private var messages: [[String: String]] = []
    @State private var inputText: String = ""
    @State private var isStream: Bool = false
    @State private var isStreaming: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var streamContent = ""
    
    let apiKey = "2294b6327344df7d347bc489368dcd17"
    let secret = "sk-4fe70ed22136a48f3e882d448cbc9fa5"
    
    ///Atom-1B-Chat(llama.family)模型 默认为 557ca23b-841a-4fc8-9eb3-638e8cf8f791
    ///Atom-7B-Chat(llama.family)模型 默认为 bdbefed4-03a8-4e32-b650-974246184783
    ///Atom-13B-Chat(llama.family)模型 默认为 3bf4d1af-38ce-4e94-939e-b1002b0b8455
    let modelId = "3bf4d1af-38ce-4e94-939e-b1002b0b8455"
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(messages, id: \.self) { message in
                        HStack {
                            if message["role"] == "Human" {
                                Spacer()
                                Text(message["content"]!)
                                    .padding(10)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            } else {
                                Text(message["content"]!)
                                    .padding(10)
                                    .foregroundColor(.black)
                                    .background(Color(UIColor.systemGray5))
                                    .cornerRadius(10)
                                Spacer()
                            }
                        }
                    }
                }
            }
            
            HStack {
                TextField("Type your message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disabled(isStreaming) // 禁用文本输入
                
                Button(action: sendMessage) {
                    Text(isStreaming ? "Stop" : "Send")
                }
                .disabled(inputText.isEmpty || isStreaming) // 禁用按钮
            }
            .padding()
        }
        .onAppear(perform: initializeChat)
        .overlay(
            Group {
                if isLoading {
                    ProgressView()
                }
            }
        )
    }
    
    func initializeChat() {
        messages.append(["role": "Human", "content": "你好"])
        messages.append(["role": "Assistant", "content": "你好呀!"])
    }
    
    func sendMessage() {
        if isStreaming {
            isStreaming = false
            return
        }
        
        messages.append(["role": "Human", "content": inputText])
        inputText = ""
        
        if isStream {
            streamChat()
        } else {
            sendNonStreamChat()
        }
    }
    
    func sendNonStreamChat() {
        isLoading = true
        Task {
            let response = try await sendNonStreamRequest()
            messages.append(["role": "Assistant", "content": response])
            isLoading = false
        }
    }
    
    func streamChat() {
        isStreaming = true
        streamContent = ""
        messages.append(["role": "Assistant", "content": "..."])
        Task {
            try await streamRequest { content in
                DispatchQueue.main.async {
                    messages[messages.count-1]["content"] = content
                }
            }
            isStreaming = false
        }
    }
    
    func sendNonStreamRequest() async throws -> String {
        let url = URL(string: "https://api.atomecho.cn/open/text-chat/v1")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "S-Auth-ApiKey")
        request.addValue(secret, forHTTPHeaderField: "S-Auth-Secret")
        
        let body = [
            "param": [
                "model": modelId,
                "stream": false
            ],
            "messages": messages
        ] as [String : Any]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let data = jsonData["data"] as? [String: Any],
           let content = data["content"] as? String {
            return content
        } else {
            throw NSError(domain: "com.example.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
    }
    
    func streamRequest(_ updateCallback: @escaping (String) -> Void) async throws {
        let url = URL(string: "https://api.atomecho.cn/open/text-chat/v1")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.addValue(apiKey, forHTTPHeaderField: "S-Auth-ApiKey")
        request.addValue(secret, forHTTPHeaderField: "S-Auth-Secret")
        
        let body = [
            "param": [
                "model": modelId,
                "stream": true
            ],
            "messages": messages
        ] as [String : Any]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let (stream, _) = try await URLSession.shared.bytes(for: request)
        
        var content = ""
        for try await line in stream.lines {
            if line.starts(with: "data:") {
                let jsonData = line.dropFirst(5).data(using: .utf8)
                if let jsonString = String(data: jsonData!, encoding: .utf8), !jsonString.isEmpty {
                    if let json = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String: Any],
                       let data = json["data"] as? [String: Any],
                       let contentChunk = data["content"] as? String {
//                        content += contentChunk
                        if !contentChunk.isEmpty {
                            updateCallback(contentChunk)
                        }
                    }
                }
            } else if line == "data:" {
                if !content.isEmpty {
                    updateCallback(content)
                    content = ""
                }
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
