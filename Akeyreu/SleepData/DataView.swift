//
//  DataView.swift
//  Akeyreu
//
//  Created by Asher Amey on 5/24/24.
//

import Foundation
import SwiftUI

struct DataResponse: Codable {
    let heartRate: Int
    let hoursSlept: Double
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let role: String
        let content: String
    }

    let choices: [Choice]
}

func fetchOpenAIResponse(prompt: String, completion: @escaping (String?) -> Void) {
    let apiKey = "sk-proj-cRGf5W3LMCSXvJJ6r8mcT3BlbkFJ8tuSE3yo1jEzwWkuKBKG"

    guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
        print("Invalid URL")
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    let parameters: [String: Any] = [
        "model": "gpt-4",
        "messages": [
            [
                "role": "system",
                "content": "You are a helpful assistant."
            ],
            [
                "role": "user",
                "content": prompt
            ]
        ],
        "max_tokens": 100
    ]

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: parameters)
        request.httpBody = jsonData
        print("Request JSON: \(String(data: jsonData, encoding: .utf8)!)")
    } catch {
        print("Failed to serialize JSON: \(error)")
        completion(nil)
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(nil)
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                print("Failed with status code: \(httpResponse.statusCode)")
                completion(nil)
                return
            }
        }

        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }

        print("Response Data: \(String(data: data, encoding: .utf8)!)")

        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(OpenAIResponse.self, from: data)
            completion(response.choices.first?.message.content)
        } catch {
            print("Error decoding response: \(error)")
            completion(nil)
        }
    }

    task.resume()
}

struct DataView: View {
    @State private var hoursSlept: String = ""
    @State private var heartRate: String = ""
    @State private var responseText = "Waiting for response..."
    @State private var userPrompt = ""
    
    var body: some View {
        VStack {
            Text("Last Night's Sleep")
                .font(.title3)
                .fontWeight(.bold)
                .padding()
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 350, height: 300)
                .cornerRadius(10)
                .overlay(
                    Text("Graph Placeholder")
                        .foregroundColor(.gray)
                        .font(.headline)
                )
                .padding()
            
            HStack (spacing: 10){
                Text("Hours Slept: \(hoursSlept)")
                    .font(.subheadline)
                    .padding()
                Text("Average Heart Rate: \(heartRate)")
                    .font(.subheadline)
                    .padding()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            VStack {
                Text("AI Insights")
                    .font(.title3)
                    //.padding()
                
                TextField("Enter prompt", text: $userPrompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    //.padding()
                
                ScrollView {
                    TextEditor(text: $responseText)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 100, maxHeight: .infinity)
                        .padding()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .frame(minHeight: 150)
                
                Button(action: {
                    fetchOpenAIResponse(prompt: userPrompt) { response in
                        if let response = response {
                            responseText = response
                        } else {
                            responseText = "Failed to get response"
                        }
                    }
                }) {
                    Text("Fetch Response")
                }
                .padding()
            }
            
            Spacer()
        } //HStack
        .frame(maxWidth: 350, maxHeight: .infinity)
        .background(Color.white)
        .onAppear() {
            print("loaded")
            //fetchData()
        }
    } //body
    
    func fetchData() {
        let url = URL(string: "akeyreu.com")!
        
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(String(describing: error))")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(DataResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.heartRate = "\(response.heartRate) bpm"
                    self.hoursSlept = "\(response.hoursSlept) hours"
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        
        task.resume()
    }
} //DataView

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}
