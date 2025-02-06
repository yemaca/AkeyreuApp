//
//  RokuDiscovery.swift
//  Akeyreu
//
//  Created by Asher Amey on 9/18/24.
//

import Foundation
import Network

class RokuDiscovery {
    static let shared = RokuDiscovery()
    private let multicastAddress = "239.255.255.250"
    private let port: NWEndpoint.Port = 1900
    private let searchTarget = "roku:ecp"
    
    func discover(completion: @escaping ([RokuTVControl]) -> Void) {
        var discoveredDevices: [RokuTVControl] = []
        
        let message = "M-SEARCH * HTTPS/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 3\r\nST: roku:ecp\r\n\r\n"

        
        print("Sending SSDP request")
        
        guard let messageData = message.data(using: .utf8) else {
            print("Failed to create message data")
            completion([])
            return
        }
        
        let params = NWParameters.udp
        let connection = NWConnection(host: NWEndpoint.Host(multicastAddress), port: port, using: params)
        
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Connection ready. Sending SSDP message...")
                connection.send(content: messageData, completion: .contentProcessed { sendError in
                    if let error = sendError {
                        print("Send error: \(error)")
                        connection.cancel()
                        completion(discoveredDevices)
                        return
                    }
                    self.receiveResponses(on: connection) { devices in
                        discoveredDevices.append(contentsOf: devices)
                        print("Discovered devices: \(discoveredDevices)")
                        completion(discoveredDevices)
                    }
                })
                case .setup:
                    print("Connection is in setup state")
                case .preparing:
                    print("Connection is preparing")
                case .waiting(let error):
                    print("Connection is waiting, error: \(error)")
                case .failed(let error):
                    print("Connection failed: \(error)")
                    connection.cancel()
                    completion(discoveredDevices)
                case .cancelled:
                    print("Connection cancelled")
                default:
                    print("Unknown state: \(state)")
            }
        }
        
        connection.start(queue: .global())
    }


    
    private func receiveResponses(on connection: NWConnection, completion: @escaping ([RokuTVControl]) -> Void) {
        var discoveredDevices: [RokuTVControl] = []
        print("in receiveresponse")
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { data, _, isComplete, error in
            if let data = data, let response = String(data: data, encoding: .utf8) {
                print("Received SSDP response: \(response)")  // Debugging log
                
                if let device = self.parseResponse(response) {
                    print("Parsed device: \(device.getName()) at \(device.getIP())")  // Debugging log
                    if !discoveredDevices.contains(where: { $0.getIP() == device.getIP() }) {
                        discoveredDevices.append(device)
                    }
                }
            } else {
                print("No data or error: \(error?.localizedDescription ?? "None")")  // Debugging log
            }
            
            if isComplete || error != nil {
                connection.cancel()
                print("Discovery complete with devices: \(discoveredDevices)")  // Debugging log
                completion(discoveredDevices)
            } else {
                self.receiveResponses(on: connection, completion: completion)
            }
        }
    }
    
    private func parseResponse(_ response: String) -> RokuTVControl? {
        // Split the response string using both \n and \r\n as line separators
        let lines = response.components(separatedBy: CharacterSet.newlines)
        var locationURL: String?
        
        print("in parse response")

        for line in lines {
            if line.lowercased().starts(with: "location:") {
                locationURL = line.dropFirst("location:".count).trimmingCharacters(in: .whitespaces)
                break
            }
        }

        guard let location = locationURL, let url = URL(string: location) else {
            return nil
        }

        // Fetch device description XML
        if let data = try? Data(contentsOf: url), let xml = String(data: data, encoding: .utf8) {
            let name = self.extractXMLValue(xml: xml, tag: "friendlyName") ?? "Unknown"
            let ip = url.host ?? "Unknown"
            return RokuTVControl(name: name, ip: ip)
        }

        return nil
    }

    private func extractXMLValue(xml: String, tag: String) -> String? {
        guard let startRange = xml.range(of: "<\(tag)>"),
              let endRange = xml.range(of: "</\(tag)>", range: startRange.upperBound..<xml.endIndex) else {
            return nil
        }
        return String(xml[startRange.upperBound..<endRange.lowerBound])
    }
}
