//
//  RokuScanner.swift
//  Akeyreu
//
//  Created by Asher Amey on 10/14/24.
//

/*
 this version scans
 */
import CocoaAsyncSocket

class RokuScanner: NSObject, GCDAsyncUdpSocketDelegate {
    var udpSocket: GCDAsyncUdpSocket!
    var discoveredDevices: [(name: String, ip: String)] = [] // Store found devices
    var completionHandler: (([(String, String)]) -> Void)? // Completion handler

    func discoverDevices(completion: @escaping ([(String, String)]) -> Void) {
        self.completionHandler = completion
        discoveredDevices.removeAll()
        
        print("Starting SSDP discovery...")
        setupSSDP()

        // Wait 3 seconds for SSDP responses
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if self.discoveredDevices.isEmpty {
                print("No devices found via SSDP. Starting direct IP scan...")
                self.scanNetworkForRokuDevices()
            } else {
                print("SSDP discovery successful. Found \(self.discoveredDevices.count) device(s).")
                completion(self.discoveredDevices)
                self.udpSocket.close()
            }
        }
    }

    // MARK: - SSDP Discovery
    private func setupSSDP() {
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try udpSocket.enableBroadcast(true)
            try udpSocket.bind(toPort: 0) // Use an available port
            try udpSocket.beginReceiving()
            try udpSocket.joinMulticastGroup("239.255.255.250") // Join SSDP group
            print("Socket successfully configured for multicast.")
        } catch {
            print("Failed to setup UDP socket: \(error)")
            return
        }
        
        sendSSDPDiscoveryRequest()
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
            print("SSDP discovery request sent.")
        }
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard let host = GCDAsyncUdpSocket.host(fromAddress: address),
              let response = String(data: data, encoding: .utf8) else {
            return
        }

        if response.contains("Roku") {
            if !discoveredDevices.contains(where: { $0.ip == host }) {
                discoveredDevices.append((name: "Roku Device", ip: host))
                print("Discovered Roku via SSDP at \(host)")
            }
        }
    }

    // MARK: - Direct IP Scanning (Fallback)
    private func scanNetworkForRokuDevices() {
        guard let baseIP = getLocalNetworkBaseIP() else {
            print("Unable to determine local network range.")
            completionHandler?([])
            return
        }
        
        let dispatchGroup = DispatchGroup()

        for i in 1...50 { // Limit scanning to first 50 IPs for faster results
            let ip = "\(baseIP).\(i)"
            dispatchGroup.enter()
            checkRokuDevice(at: ip) {
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("Direct IP scanning complete. Found \(self.discoveredDevices.count) device(s).")
            self.completionHandler?(self.discoveredDevices)
        }
    }

    private func checkRokuDevice(at ip: String, completion: @escaping () -> Void) {
        guard let url = URL(string: "http://\(ip):8060/query/device-info") else {
            completion()
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    if !self.discoveredDevices.contains(where: { $0.ip == ip }) {
                        self.discoveredDevices.append((name: "Roku Device", ip: ip))
                        print("Discovered Roku via direct scan at \(ip)")
                    }
                }
            }
            completion()
        }
        task.resume()
    }

    private func getLocalNetworkBaseIP() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) && addr.sa_family == UInt8(AF_INET) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        let ip = String(cString: hostname)
                        if ip.starts(with: "192.168.") || ip.starts(with: "10.") {
                            address = ip
                            break
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        if let address = address, let lastDot = address.lastIndex(of: ".") {
            return String(address[..<lastDot]) // Return base IP (e.g., "192.168.1")
        }
        return nil
    }
}

/*
 old version using multicast (ssdp) scanning
 did not work on my wifi bc it blocks it
 */
//
//import CocoaAsyncSocket
//
//class RokuScanner: NSObject, GCDAsyncUdpSocketDelegate {
//    var udpSocket: GCDAsyncUdpSocket!
//    var discoveredDevices: [(name: String, ip: String)] = [] // Array to store discovered devices
//
//    func discoverDevices(completion: @escaping ([(String, String)]) -> Void) {
//        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
//        do {
//            try udpSocket.enableBroadcast(true)
//            try udpSocket.bind(toPort: 0) // Use an available port
//            try udpSocket.beginReceiving()
//        } catch {
//            print("Error setting up UDP socket: \(error)")
//            completion([])
//            return
//        }
//
//        sendSSDPDiscoveryRequest()
//
//        // Wait 3 seconds for responses, then call completion
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            completion(self.discoveredDevices)
//            self.udpSocket.close()
//        }
//    }
//
//    private func sendSSDPDiscoveryRequest() {
//        let message = """
//        M-SEARCH * HTTP/1.1\r
//        HOST: 239.255.255.250:1900\r
//        MAN: "ssdp:discover"\r
//        MX: 3\r
//        ST: roku:ecp\r
//        \r
//        """
//        if let data = message.data(using: .utf8) {
//            udpSocket.send(data, toHost: "239.255.255.250", port: 1900, withTimeout: 2, tag: 0)
//        }
//    }
//
//    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
//        guard let host = GCDAsyncUdpSocket.host(fromAddress: address),
//              let response = String(data: data, encoding: .utf8) else {
//            return
//        }
//
//        if response.contains("Roku") {
//            if let locationLine = response.components(separatedBy: "\r\n").first(where: { $0.contains("LOCATION:") }),
//               let location = locationLine.split(separator: " ").last {
//                discoveredDevices.append((name: "Roku Device", ip: host))
//            }
//        }
//    }
//}
