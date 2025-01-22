//
//  ContentView.swift
//  AkWatch Watch App
//
//  Created by Kayvan Fouladinovid on 11/19/23.
//THE WATCH

import SwiftUI
import CoreMotion
import HealthKit
import WatchConnectivity





struct ContentView: View {
    let healthStore: HKHealthStore = HKHealthStore.init()
    var logs : String = ""
    let x = wc.init(sp:SleepStatus.init())
    


    var body: some View {
        
        VStack {
            Button {
                self.viewDidLoad()
           
            } label: {
                Text("Start Connection")
            }


        }
        .padding()
    }
    
    func viewDidLoad() {
        print( WCSession.default.isCompanionAppInstalled)
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = x
            session.activate()
        }

        let typestoRead = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ])
        
        let typestoShare = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ])
        
        self.healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
            if success == false {
                NSLog(" Display not allowed")
            }
        }
    }
}
#Preview {
    ContentView()
}



