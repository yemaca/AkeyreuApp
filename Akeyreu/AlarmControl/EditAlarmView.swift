//
//  EditAlarmView.swift
//  Akeyreu
//
//  Created by Asher Amey on 2/17/25.
//

import SwiftUI

struct EditAlarmView: View {
    @ObservedObject var alarmManager: AlarmManager
    var alarmIndex: Int
  
    @State private var selectedTime: Date
    @State private var repeatDays: [String]
    @State private var selectedSound: String
    
    @Environment(\.dismiss) var dismiss
    
    let availableSounds = ["Bell", "Dream", "Pleasant"]
    
    init(alarmManager: AlarmManager, alarmIndex: Int) {
        self.alarmManager = alarmManager
        self.alarmIndex = alarmIndex
        
        let alarm = alarmManager.alarms[alarmIndex]
        _selectedTime = State(initialValue: alarm.time)
        _repeatDays = State(initialValue: alarm.repeatDays)
        _selectedSound = State(initialValue: alarm.sound)
    }
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                
                Section(header: Text("Repeat Days")) {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        Button(action: {
                            if repeatDays.contains(day) {
                                repeatDays.removeAll { $0 == day }
                            } else {
                                repeatDays.append(day)
                            }
                        }) {
                            HStack {
                                Text(day)
                                Spacer()
                                if repeatDays.contains(day) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Alarm Sound")) {
                    Picker("Select Sound", selection: $selectedSound) {
                        ForEach(availableSounds, id: \.self) { sound in
                            Text(sound)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Edit Alarm")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        alarmManager.updateAlarm(at: alarmIndex, time: selectedTime, repeatDays: repeatDays, sound: selectedSound)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
