//
//  SleepStatus.swift
//  Akeyreu
//
//  Created by Kayvan Fouladinovid on 12/16/23.
//

import Foundation
import HealthKit
import CoreMotion
import WatchConnectivity

class SleepStatus: ObservableObject {
    @Published var logs: String = ""
    var healthStore : HKHealthStore = HKHealthStore.init()
    var sleepStates: [HKCategorySample] = []
    let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos     : .background)
    let oQ = OperationQueue()
    let motionManager = CMMotionActivityManager()
    var stationary = false
    var send :[String:String] = [:]
    private var heartRate: Double = 0
    var stageInDemo = 0
    let deviceManager = IOT()
    
    init() {
        logs += "Controller Init"
        dispatchQueue.async{
            self.run();
        }
    }
    func run(){
        while(true){
            getHeartRate()
            updateSleepStatus();
            
            do {
                try WCSession.default.updateApplicationContext(["A":Int.random(in: 0..<6)])
                print("GO sent update application context")
            }
            catch{print("ERROR sendinng update ApplicationContext")}
            sleep(5)

            print(self.send)
            //determinePhaseChange()
            
            if (heartRate > 100 && self.stationary == false && stageInDemo < 5)
            {
                self.deviceManager.noMotion100()
                stageInDemo += 1

            }
            else if (heartRate > 100 && self.stationary == true && stageInDemo < 4)
            {
                self.deviceManager.motion100()
                stageInDemo += 1

            }
            else if (heartRate > 90 && self.stationary == false && stageInDemo < 3)
            {
                self.deviceManager.noMotion90()
                stageInDemo += 1

            }
            else if(heartRate > 90 && self.stationary == true && stageInDemo < 2)
            {
                self.deviceManager.motion90()
                stageInDemo += 1

            }
            else {
                self.deviceManager.noMotionRest()
                stageInDemo += 1
            }
        }
    }
    private func getHeartRate() {
            let healthStore = HKHealthStore()
            let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            let date = Date()
            let predicate = HKQuery.predicateForSamples(withStart: date.addingTimeInterval(-60000), end: date, options: .strictEndDate)
            let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
                guard let result = result, let quantity = result.averageQuantity() else {
                    self.send["HR"] = "NONE"
                    return
                }
                self.heartRate = quantity.doubleValue(for: HKUnit(from: "count/min"))
                self.send["HR"] = String(self.heartRate)
                
            }
            healthStore.execute(query)
        }
    

    func updateMotionStatus(){
        let calendar = Calendar.current
        motionManager.queryActivityStarting(from: calendar.startOfDay(for: Date()),
                                            to: Date(), to: OperationQueue.main)
        {(motionActivities, error) in
            let currActivity =  motionActivities!.last!
            if currActivity.stationary {
                self.send["Stationary"] = "True"
            }
            else {
                self.send["Stationary"] = "False"
            }
        }
    }

    
    func updateSleepStatus(){
        let sleepSampleType = HKCategoryType(.sleepAnalysis)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sleepSampleType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor])
        {
            [self] (query, tmpResult, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            
            if let sample = tmpResult?[0] as? HKCategorySample {
                if (sleepStates.isEmpty || sample != sleepStates[(sleepStates.endIndex) - 1]) {
                    //sleep status changed
                    //Call sleep status change function
                    sleepStates.append(sample)
                    send["Sleep"] = sts(val: sample.value)
                }
            }
        }
        
        self.healthStore.execute(query)
    }
  

    
    func sts(val:Int)->String{
        switch(val){
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            return "asleep Rem"
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            return "asleep Core"
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            return "asleep Deep"
        case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
            return "asleep Unspecified"
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            return "Awake"
        case HKCategoryValueSleepAnalysis.inBed.rawValue:
            return "In Bed"
        default:
            return "No Value"
        }
    }
    

    //Call when sleep changes
    func determinePhaseChange(){
        //Do nothing they are at best two states away from falling asleep. Awake -> inbed -> asleep light
        if self.sleepStates.last!.value == HKCategoryValueSleepAnalysis.awake.rawValue{
            print("User was not in bed")
        }
        //From in bed to either awake or alseep
        if self.sleepStates.last!.value == HKCategoryValueSleepAnalysis.inBed.rawValue{
            if self.stationary{
                print("Deeper Sleep")
                //DIM LIGHTS
            }
            else {
                print("Sleep Aborted after in bed")
                //Keep lights as is
            }
        }
        //One of the categories that indicate asleep.
        else {
            if self.stationary{
                print("User is going from sleep state to another")
                //Either Dims lights to off or keep off
            }
            else {
                print("User Woke up")
                //show dim lights
            }
        }
    }
}

