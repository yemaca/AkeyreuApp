//
//  DeviceControl.swift
//  Akeyreu
//
//  Created by Asher Amey on 8/12/24.
//
import SwiftUI

struct DeviceDiscoveryView: View {
    @State private var devices: [RokuTVControl] = [] {
        didSet {
            saveDevices()
        }
    }
    @State private var discoveryInProgress = false
    @State private var selectedDevice: RokuTVControl?

    var body: some View {
        NavigationStack {
            VStack {
                if discoveryInProgress {
                    ProgressView("Discovering Devices...")
                        .padding()
                }

                List {
                    ForEach(devices, id: \.identifier) { device in
                        Button(action: {
                            selectedDevice = device
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

                NavigationLink(destination: RokuDeviceControlView(device: $selectedDevice, saveDevices: saveDevices),
                               isActive: Binding(
                                   get: { selectedDevice != nil },
                                   set: { if !$0 { selectedDevice = nil } }
                               )
                ) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("Device Discovery")
            .onAppear {
                loadDevices()
                if devices.isEmpty {
                    discoverDevices()
                }
            }
        }
    }

    private func saveDevices() {
        do {
            let data = try JSONEncoder().encode(devices)
            UserDefaults.standard.set(data, forKey: "savedDevices")
            print("Devices saved successfully.")
        } catch {
            print("Failed to save devices: \(error)")
        }
    }

    private func loadDevices() {
        guard let data = UserDefaults.standard.data(forKey: "savedDevices") else { return }
        do {
            devices = try JSONDecoder().decode([RokuTVControl].self, from: data)
            print("Devices loaded successfully.")
        } catch {
            print("Failed to load devices: \(error)")
        }
    }

    private func discoverDevices() {
        discoveryInProgress = true
        RokuScanner().discoverDevices { discoveredDevices in
            DispatchQueue.main.async {
                for (name, ip) in discoveredDevices {
                    if !devices.contains(where: { $0.getIP() == ip }) {
                        let newDevice = RokuTVControl(name: name, ip: ip)
                        devices.append(newDevice)
                    }
                }
                discoveryInProgress = false
            }
        }
    }
}

struct DeviceDiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDiscoveryView()
    }
}
