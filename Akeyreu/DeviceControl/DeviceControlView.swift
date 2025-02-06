//
//  DeviceDiscoveryView.swift
//  Akeyreu
//
//  Created by Asher Amey on 1/8/25.
//


import SwiftUI

struct DeviceControlView: View {
    @Binding var device: RokuTVControl? // Device to control
    
    @State private var newName: String = "" // Temporary state for renaming
    @State private var navName: String = ""
    @State private var turnOffTime: Date = Date() // State for selected turn-off time
    @State private var isScheduled = false
    
    var body: some View {
        VStack {
            if let device = device {
                Text("Controlling \(device.getName())")
                    .foregroundColor(.black)
                    .font(.title)
                    .padding()
                
                // Rename Device Section
                TextField("Rename Device", text: $newName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onAppear {
                        newName = device.getName() // Load current name
                        navName = device.getName()
                    }
                    .onSubmit {
                        device.setName(newName) // Update the device name
                        navName = newName
                        print("\(newName)")
                    }
                
                Button(action: {
                    print(device.identifier)
                }) {
                    Text("ID")
                        .foregroundColor(.black)
                }
                .padding()
                
                HStack {
                    Button(action: {
                        device.togglePower { success in
                            print("Power toggled for \(device.getName()): \(success ? "Success" : "Failure")")
                        }
                    }) {
                        Text("⏻")
                            .padding(10)
                    }
                    .border(Color.blue, width: 1)
                    .background(Color.white)
                    .padding()
                    
                    Button(action: {
                        device.home { success in
                            print("Home for \(device.getName()): \(success ? "Success" : "Failure")")
                        }
                    }) {
                        Text("⌂")
                            .font(.system(size: 25))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                    .border(Color.blue, width: 1)
                    .background(Color.white)
                    .padding()
                }
                .padding()
                
                HStack {
                    Button(action: {
                        device.volumeUp { success in
                            print("Volume up for \(device.getName()): \(success ?"Success" : "Failure")")
                        }
                    }) {
                        Text("Volume Up")
                            .padding(10)
                    }
                    .border(Color.blue, width: 1)
                    .background(Color.white)
                    .padding()
                    
                    Button(action: {
                        device.volumeDown { success in
                            print("Volume down for \(device.getName()): \(success ?"Success" : "Failure")")
                        }
                    }) {
                        Text("Volume Down")
                            .padding(10)
                    }
                    .border(Color.blue, width: 1)
                    .background(Color.white)
                    .padding()
                }
                
                Button(action: {
                    device.up { success in
                        print("Up for \(device.getName()): \(success ?"Success" : "Failure")")
                    }
                }) {
                    Text("↑")
                        .padding(10)
                }
                .border(Color.blue, width: 1)
                .background(Color.white)
                .padding()
                
                HStack {
                    Button(action: {
                        device.left { success in
                            print("Left for \(device.getName()): \(success ?"Success" : "Failure")")
                        }
                    }) {
                        Text("←")
                            .padding(10)
                    }
                    .border(Color.blue, width: 1)
                    .background(Color.white)
                    .padding()
                    
                    Button(action: {
                        device.select { success in
                            print("Select for \(device.getName()): \(success ?"Success" : "Failure")")
                        }
                    }) {
                        Text("OK")
                            .padding(10)
                    }
                    .border(Color.blue, width: 1)
                    .background(Color.white)
                    .padding()
                    
                    Button(action: {
                        device.right { success in
                            print("Right for \(device.getName()): \(success ?"Success" : "Failure")")
                        }
                    }) {
                        Text("→")
                            .padding(10)
                    }
                    .border(Color.blue, width: 1)
                    .background(Color.white)
                    .padding()
                }
                
                Button(action: {
                    device.down { success in
                        print("Down for \(device.getName()): \(success ?"Success" : "Failure")")
                    }
                }) {
                    Text("↓")
                        .padding(10)
                }
                .border(Color.blue, width: 1)
                .background(Color.white)
                .padding()
                
                // Button to schedule turn-off
                if !isScheduled {
                    DatePicker(
                        "Set Turn-Off Time",
                        selection: $turnOffTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                    .background(Color.white)
                    .padding()
                    
                    Button("Schedule Turn-Off") {
                        scheduleTurnOff()
                    }
                    .foregroundColor(.black)
                    .padding()
                }
                else {
                    Text("Turn-Off scheduled for \(formattedTime(turnOffTime))")
                        .font(.footnote)
                        .foregroundColor(.black)
                    Button("Remove Turn-Off Time") {
                        cancelTurnOff()
                    }
                    .foregroundColor(.black)
                }
            } else {
                Text("No device selected.")
                    .font(.title)
            }
        }
        .padding()
        .navigationTitle("")    // remove default nav bar styling
        .toolbar {              // set custom style
            ToolbarItem(placement: .principal) {
                Text(navName)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
//        .background(Color(hex: "#035aa6"))
    }
    
    private func scheduleTurnOff() {
        let timeInterval = turnOffTime.timeIntervalSinceNow
        if timeInterval > 0 {
            isScheduled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                guard isScheduled else { return }
                device?.powerOff { success in
                    print("Device turned off at scheduled time: \(success ? "Success" : "Failure")")
                }
                isScheduled = false // Reset after turn-off
            }
        } else {
            print("Invalid turn-off time.")
        }
    }
    
    private func cancelTurnOff() {
        isScheduled = false
        print("Turn off canceled")
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
