//
//  RokuTVControl.swift
//  Akeyreu
//
//  Created by Asher Amey on 8/21/24.
//

import Foundation

class RokuTVControl: ObservableObject, Identifiable, Codable {
    private let ip: String
    @Published var name: String
    private let port: Int = 8060
    private var lastState: Bool = false

    enum CodingKeys: String, CodingKey {
        case name
        case ip
        case lastState
    }

    // Designated initializer
    init(name: String, ip: String) {
        self.name = name
        self.ip = ip
    }

    // Required initializer for decoding
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.ip = try container.decode(String.self, forKey: .ip)
        self.lastState = try container.decode(Bool.self, forKey: .lastState)
    }

    // Method for encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(ip, forKey: .ip)
        try container.encode(lastState, forKey: .lastState)
    }

    private func sendCommand(_ command: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://\(ip):\(port)/\(command)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send command: \(command), error: \(error)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Command \(command) sent successfully.")
                completion(true)
            } else {
                print("Failed to send command: \(command)")
                completion(false)
            }
        }
        task.resume()
    }
    
    func fetchPowerState(completion: @escaping (Bool?) -> Void) {
        guard let url = URL(string: "http://\(ip):\(port)/query/device-info") else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch device info: \(error)")
                completion(nil)
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                // Parse the power state from the response XML
                if responseString.contains("<power-mode>PowerOn</power-mode>") {
                    completion(true) // Powered On
                } else if responseString.contains("<power-mode>Standby</power-mode>") {
                    completion(false) // Powered Off
                } else {
                    completion(nil) // Unknown state
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func togglePower(completion: @escaping (Bool) -> Void) {
        fetchPowerState { isPoweredOn in
            guard let isPoweredOn = isPoweredOn else {
                print("Failed to determine power state.")
                completion(false)
                return
            }
            
            let response = isPoweredOn ? "<power-mode>PowerOn</power-mode> - need to turn power off" : "<power-mode>Standby</power-mode> - need to turn power on"
            print("Response from power state:\n\(response)\n")
            
            let command = self.lastState ? "keypress/PowerOff" : "keypress/Home"
            print("Command based on lastState - \(command)")
            self.changeState()
            
            self.sendCommand(command) { success in
                completion(success)
            }
        }
    }
    
    func powerOff(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/PowerOff", completion: completion)
    }
    
    func volumeUp(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/VolumeUp", completion: completion)
    }
    
    func volumeDown(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/VolumeDown", completion: completion)
    }
    
    func home(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/Home", completion: completion)
    }
    
    func select(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/Select", completion: completion)
    }
    
    func up(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/Up", completion: completion)
    }
    
    func down(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/Down", completion: completion)
    }
    
    func left(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/Left", completion: completion)
    }
    
    func right(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/Right", completion: completion)
    }

    func back(completion: @escaping (Bool) -> Void) {
        sendCommand("keypress/Back", completion: completion)
    }

    func launchApp(appID: String, completion: @escaping (Bool) -> Void) {
        sendCommand("launch/\(appID)", completion: completion)
    }
    
    func getName() -> String {
        return name
    }
    
    func setName(_ newName: String) {
        name = newName
    }
    
    func getIP() -> String {
        return ip
    }
    
    func changeState() {
        self.lastState.toggle()
    }
    
    var identifier: String {
        return "\(name)-\(ip)"
    }
}
