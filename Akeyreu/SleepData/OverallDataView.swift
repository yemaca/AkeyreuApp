//
//  DataView.swift
//  Akeyreu
//
//  Created by Asher Amey on 5/24/24.
//

import Foundation
import SwiftUI

struct OverallDataView: View {
    @State private var hoursSlept = ""
    @State private var heartRate = ""
    
    var body: some View {
        VStack {
            Text("Sleep Data")
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
                Text("Avg Hours Slept: \(hoursSlept)")
                    .font(.subheadline)
                    .padding()
                Text("Avg Heart Rate: \(heartRate)")
                    .font(.subheadline)
                    .padding()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            VStack {
                Text("Actionable Insights")
                    .font(.title3)
            }
            
            Spacer()
        } //HStack
        .frame(maxWidth: 350, maxHeight: .infinity)
        .background(Color.white)
        .onAppear() {
            fetchData()
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

struct OverallDataView_Previews: PreviewProvider {
    static var previews: some View {
        OverallDataView()
    }
}
