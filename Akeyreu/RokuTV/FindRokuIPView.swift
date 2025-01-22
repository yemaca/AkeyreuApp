//
//  FindRokuIPView.swift
//  Akeyreu
//
//  Created by Asher Amey on 9/24/24.
//

import SwiftUI

struct FindRokuIPView: View {
    var body: some View {
        VStack {
            Text("How to Find Your Roku IP Address")
                .font(.title)
                .padding()

            Text("1. Press the Home button on your Roku remote.")
            Text("2. Scroll down and select 'Settings'.")
            Text("3. Go to 'Network'.")
            Text("4. Select 'About'.")
            Text("5. Your IP address will be listed on this screen.")

            Spacer()
        }
        .padding()
        .navigationBarTitle("Roku IP Address", displayMode: .inline)
    }
}
