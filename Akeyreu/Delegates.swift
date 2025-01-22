//
//  Delegates.swift
//  Akeyreu
//
//  Created by Kayvan Fouladinovid on 12/16/23.
//

import Foundation
import WatchConnectivity
import os

class wc:NSObject, WCSessionDelegate{
    let logger = Logger()
    var sp : SleepStatus
    init(sp: SleepStatus) {
        self.sp = sp
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
        print ("INACTIVE PHONE")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("DEACTIVE PHONE")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("SESSION DELEGATE")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print ("InComing " + (message["Stationary"] as? String ?? "Unknown"))
            print(message)
            
            if let status = message["Stationary"] {
                if status as! String == "true"{
                    self.sp.stationary = true
                    self.sp.send["Stationary"] = "true"
                }
                else {
                    self.sp.stationary = false
                    self.sp.send["Stationary"] = "false"
                }
            }
            else
            {
                self.sp.stationary = false
                self.sp.send["Stationary"] = "Unknown"
            }
            
        }
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Recievded application context")
    }
}
