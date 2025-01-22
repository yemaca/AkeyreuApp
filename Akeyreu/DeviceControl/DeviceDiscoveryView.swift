//
//  DeviceControl.swift
//  Akeyreu
//
//  Created by Asher Amey on 8/12/24.
//

/*
 manual device input
 doesnt auto discover on phone but can send commands when manually input device
 */
import SwiftUI

struct DeviceDiscoveryView: View {
    @State private var devices: [RokuTVControl] = [] // List of discovered devices
    @State private var discoveryInProgress = false // Show progress indicator during discovery
    @State private var selectedDevice: RokuTVControl? // Selected device for navigation
    @State private var showingAddDeviceSheet = false // Controls the add device sheet
    @State private var manualDeviceName = "" // Temporary name input
    @State private var manualDeviceIP = "" // Temporary IP input

    var body: some View {
        NavigationView {
            VStack {
                if discoveryInProgress {
                    ProgressView("Discovering Devices...")
                        .padding()
                }

                List {
                    ForEach(devices, id: \.identifier) { device in
                        Button(action: {
                            selectedDevice = device // Set the selected device
                        }) {
                            Text(device.getName())
                        }
                    }
                }
                .border(devices.isEmpty ? Color.clear : Color.gray, width: 1)
                .frame(height: CGFloat(devices.count) * 75)

                Button("Discover Devices") {
                    discoverDevices()
                }
                .padding()

                Button("Add Device") {
                    showingAddDeviceSheet = true
                }
                .padding()

                // Navigation to DeviceControlView
                NavigationLink(destination: DeviceControlView(device: $selectedDevice),
                               isActive: Binding(
                                   get: { selectedDevice != nil },
                                   set: { if !$0 { selectedDevice = nil } }
                               )
                ) {
                    EmptyView() // Invisible NavigationLink
                }
            }
            .padding()
            .navigationTitle("Device Discovery")
            .onAppear {
                if devices.isEmpty {
                    discoverDevices()
                }
            }
            .sheet(isPresented: $showingAddDeviceSheet) {
                VStack(spacing: 20) {
                    Text("Add Roku Device")
                        .font(.headline)
                        .padding()

                    TextField("Device Name", text: $manualDeviceName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    TextField("Device IP Address", text: $manualDeviceIP)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding()

                    Button("Save Device") {
                        if !manualDeviceName.isEmpty, !manualDeviceIP.isEmpty {
                            addManualDevice(name: manualDeviceName, ip: manualDeviceIP)
                            showingAddDeviceSheet = false
                        }
                    }
                    .padding()
                    .disabled(manualDeviceName.isEmpty || manualDeviceIP.isEmpty)

                    Button("Cancel") {
                        showingAddDeviceSheet = false
                    }
                    .foregroundColor(.red)
                }
                .padding()
            }
        }
    }

    private func discoverDevices() {
        discoveryInProgress = true
        RokuScanner().discoverDevices { discoveredDevices in
            DispatchQueue.main.async {
                for (name, ip) in discoveredDevices {
                    print("Discovered device: \(name) at \(ip)")
                    if !devices.contains(where: { $0.getIP() == ip }) {
                        let newDevice = RokuTVControl(name: name, ip: ip)
                        devices.append(newDevice)
                    }
                }
                discoveryInProgress = false
            }
        }
    }

    private func addManualDevice(name: String, ip: String) {
        let newDevice = RokuTVControl(name: name, ip: ip)
        if !devices.contains(where: { $0.getIP() == ip }) {
            devices.append(newDevice)
            print("Manually added device: \(name) at \(ip)")
        }
    }
}

struct DeviceDiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDiscoveryView()
    }
}

/*
 base version that works on laptop, not phone
 no manual input
 */
//import SwiftUI
//
//struct DeviceDiscoveryView: View {
//    @State private var devices: [RokuTVControl] = [] // List of discovered devices
//    @State private var discoveryInProgress = false // Show progress indicator during discovery
//    @State private var selectedDevice: RokuTVControl? // Selected device for navigation
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if discoveryInProgress {
//                    ProgressView("Discovering Devices...")
//                        .padding()
//                }
//
//                List {
//                    ForEach(devices, id: \.identifier) { device in
//                        Button(action: {
//                            selectedDevice = device // Set the selected device
//                        }) {
//                            Text(device.getName())
//                        }
//                    }
//                }
//                .border(devices.isEmpty ? Color.clear : Color.gray, width: 1)
//                .frame(height: CGFloat(devices.count) * 75)
//
//                Button("Discover Devices") {
//                    discoverDevices()
//                }
//                .padding()
//                
//                Button("Add Device") {
//                    
//                }
//                .padding()
//
//                // Navigation to DeviceControlView
//                NavigationLink(destination: DeviceControlView(device: $selectedDevice),
//                    isActive: Binding(
//                        get: { selectedDevice != nil },
//                        set: { if !$0 { selectedDevice = nil } }
//                    )
//                ) {
//                    EmptyView() // Invisible NavigationLink
//                }
//            }
//            .padding()
//            .navigationTitle("Device Discovery")
//            .onAppear {
//                if devices.count == 0 {
//                    discoverDevices()
//                }
//            }
//        }
//    }
//
//    private func discoverDevices() {
//        discoveryInProgress = true
//        RokuScanner().discoverDevices { discoveredDevices in
//            DispatchQueue.main.async {
//                for (name, ip) in discoveredDevices {
//                    print("Discovered device: \(name) at \(ip)")
//                    if !devices.contains(where: { $0.getIP() == ip }) {
//                        let newDevice = RokuTVControl(name: name, ip: ip)
//                        devices.append(newDevice)
//                    }
//                }
//                discoveryInProgress = false
//            }
//        }
//    }
//}
//
//struct DeviceDiscoveryView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceDiscoveryView()
//    }
//}

/*
 this version to be used for saving devices on app reload
 */
//import SwiftUI
//
//struct DeviceDiscoveryView: View {
//    @State private var devices: [RokuTVControl] = [] {
//        didSet {
//            saveDevices()
//        }
//    }
//    @State private var discoveryInProgress = false
//    @State private var selectedDevice: RokuTVControl?
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if discoveryInProgress {
//                    ProgressView("Discovering Devices...")
//                        .padding()
//                }
//
//                List {
//                    ForEach(devices, id: \.identifier) { device in
//                        Button(action: {
//                            selectedDevice = device
//                        }) {
//                            Text(device.getName())
//                        }
//                    }
//                }
//                .border(devices.isEmpty ? Color.clear : Color.gray, width: 1)
//                .frame(height: CGFloat(devices.count) * 75)
//
//                Button("Discover Devices") {
//                    discoverDevices()
//                }
//                .padding()
//
//                NavigationLink(destination: DeviceControlView(device: $selectedDevice),
//                               isActive: Binding(
//                                   get: { selectedDevice != nil },
//                                   set: { if !$0 { selectedDevice = nil } }
//                               )
//                ) {
//                    EmptyView()
//                }
//            }
//            .padding()
//            .navigationTitle("Device Discovery")
//            .onAppear {
//                loadDevices()
//                if devices.isEmpty {
//                    discoverDevices()
//                }
//            }
//        }
//    }
//
//    private func saveDevices() {
//        do {
//            let data = try JSONEncoder().encode(devices)
//            UserDefaults.standard.set(data, forKey: "savedDevices")
//            print("Devices saved successfully.")
//        } catch {
//            print("Failed to save devices: \(error)")
//        }
//    }
//
//    private func loadDevices() {
//        guard let data = UserDefaults.standard.data(forKey: "savedDevices") else { return }
//        do {
//            devices = try JSONDecoder().decode([RokuTVControl].self, from: data)
//            print("Devices loaded successfully.")
//        } catch {
//            print("Failed to load devices: \(error)")
//        }
//    }
//
//    private func discoverDevices() {
//        discoveryInProgress = true
//        RokuScanner().discoverDevices { discoveredDevices in
//            DispatchQueue.main.async {
//                for (name, ip) in discoveredDevices {
//                    if !devices.contains(where: { $0.getIP() == ip }) {
//                        let newDevice = RokuTVControl(name: name, ip: ip)
//                        devices.append(newDevice)
//                    }
//                }
//                discoveryInProgress = false
//            }
//        }
//    }
//}
//
//struct DeviceDiscoveryView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceDiscoveryView()
//    }
//}
