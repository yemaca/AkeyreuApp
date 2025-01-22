//
//  RokuScanner.swift
//  Akeyreu
//
//  Created by Asher Amey on 10/14/24.
//

import CocoaAsyncSocket

class RokuScanner: NSObject, GCDAsyncUdpSocketDelegate {
    var udpSocket: GCDAsyncUdpSocket!
    var discoveredDevices: [(name: String, ip: String)] = [] // Array to store discovered devices

    func discoverDevices(completion: @escaping ([(String, String)]) -> Void) {
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try udpSocket.enableBroadcast(true)
            try udpSocket.bind(toPort: 0) // Use an available port
            try udpSocket.beginReceiving()
        } catch {
            print("Error setting up UDP socket: \(error)")
            completion([])
            return
        }

        sendSSDPDiscoveryRequest()

        // Wait 3 seconds for responses, then call completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completion(self.discoveredDevices)
            self.udpSocket.close()
        }
    }

    private func sendSSDPDiscoveryRequest() {
        let message = """
        M-SEARCH * HTTP/1.1\r
        HOST: 239.255.255.250:1900\r
        MAN: "ssdp:discover"\r
        MX: 3\r
        ST: roku:ecp\r
        \r
        """
        if let data = message.data(using: .utf8) {
            udpSocket.send(data, toHost: "239.255.255.250", port: 1900, withTimeout: 2, tag: 0)
        }
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard let host = GCDAsyncUdpSocket.host(fromAddress: address),
              let response = String(data: data, encoding: .utf8) else {
            return
        }

        if response.contains("Roku") {
            if let locationLine = response.components(separatedBy: "\r\n").first(where: { $0.contains("LOCATION:") }),
               let location = locationLine.split(separator: " ").last {
                discoveredDevices.append((name: "Roku Device", ip: host))
            }
        }
    }
}
