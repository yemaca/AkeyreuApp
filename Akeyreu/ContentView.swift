//
//  ContentView.swift
//  IOTTEST
//
//  Created by Kayvan Fouladinovid on 9/8/23.
// THE PHOHE

// import SwiftUI
//import HealthKit
//import Foundation
//import CoreMotion
//import WatchConnectivity
//
//struct ContentView: View {
//    let healthStore: HKHealthStore = HKHealthStore.init()
//    var logs : String = ""
//   var x = wc(sp: SleepStatus.init())
//
//
//    var body: some View {
//        VStack {
//            Button {
//               // self.viewDidLoad()
//           
//            } label: {
//                Text("Nothing")
//            }
//            Button {
//                IOT.init().change_env(power: "on")
//                print ("power on has run")
//           
//            } label: {
//                Text("On")
//            }
//            Button {
//                IOT.init().change_env(power: "off")
//                print("power off has run")
//           
//            } label: {
//                Text("Off")
//                
//            }
//            NavigationView {
//                NavigationLink(destination: DeviceDiscoveryView()) {
//                    Text("Go to Detail View")
//                        .foregroundColor(.blue)
//                        .underline()
//                }
//                .padding()
//            }
//        }
//        .padding()
//    }
//    
//        
//    func viewDidLoad() {
//        if WCSession.isSupported() {
//            let session = WCSession.default
//            session.delegate = x
//            session.activate()
//        }
//        
//        let typestoRead = Set([
//            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
//            HKQuantityType.quantityType(forIdentifier: .heartRate)!
//            ])
//        
//        let typestoShare = Set([
//            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
//            HKQuantityType.quantityType(forIdentifier: .heartRate)!
//            ])
//        
//        self.healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
//            if success == false {
//                NSLog(" Display not allowed")
//            }
//        }
//    }
//  }
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//
//
//
//
//

// Create a class that is responsible for tracking sleep state. Have the function
// pull the state every x amount of time and update the sleep state
// check to see if the state has been changed
// implement logic for changing enviroment


//Testing protocols
//Add logic to log when then the app identifies a sleep change has happened
// Compare this to the time that helath kit recorded a difference

 



