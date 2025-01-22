//
//  WatchManager.swift
//  AkWatch Watch App
//
//  Created by Kayvan Fouladinovid on 12/23/23.
//

import CoreMotion
import os
class SleepStatus  {
    let logger = Logger()
    let motionManager = CMMotionActivityManager()
    var stationary = false
    var send = ["NIL":"NIL"]
    
    
    func updateMotionStatus(){
        #if DEBUG
            self.logger.notice( "Updating Motion State")
        #endif
        let calendar = Calendar.current
        
        motionManager.queryActivityStarting(from: calendar.startOfDay(for: Date()),
                                            to: Date(), to: OperationQueue.main)
        {(motionActivities, error) in
            #if DEBUG
                self.logger.log("Recieved Motion Query Results")
            #endif
            
            let currActivity =  motionActivities!.last!
            if currActivity.stationary {
                #if DEBUG
                    self.logger.log("User is Stationary")
                #endif
                
                self.send["Stationary"] = "True"
                self.stationary = true
            }
            else {
                #if DEBUG
                    self.logger.log( "User is not Stationary")
                #endif
                
                self.send["Stationary"] = "False"
                self.stationary = false
            }
        }
    }

    


}

