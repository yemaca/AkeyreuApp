//
//  Delegates.swift
//  AkWatch Watch App
//
//  Created by Kayvan Fouladinovid on 12/23/23.
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
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("SESSION DELEGATE")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        WCSession.default.sendMessage(["Stationary": "False"], replyHandler: nil)
        print("recieved a session we are not looking for")
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        WCSession.default.sendMessage(["Stationary": "False"], replyHandler: nil)
        logger.log("recieved a session we are not looking for")

    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        logger.log("Received application Context from phone on watch")
        sp.updateMotionStatus()
        logger.log("Watch Stationary is \(self.sp.stationary)")
        WCSession.default.sendMessage(["Stationary": String (sp.stationary)], replyHandler: nil)
    }
    
}
