//
//  MenuView.swift
//  Akeyreu
//
//  Created by Asher Amey on 1/22/25.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var alarmManager = AlarmManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Button to navigate to Device Discovery View
                NavigationLink(destination: DeviceDiscoveryView()) {
                    Text("Go to Device Discovery")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Button to navigate to Alarm List View
                NavigationLink(destination: AlarmListView(alarmManager: alarmManager)) {
                    Text("Go to Alarm View")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Main Menu")
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
