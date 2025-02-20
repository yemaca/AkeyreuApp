//
//  AddAlarmView.swift
//  Akeyreu
//
//  Created by Asher Amey on 1/22/25.
//

import SwiftUI

struct AddAlarmView: View {
    @ObservedObject var alarmManager: AlarmManager
    @State private var selectedTime = Date()
    @State private var repeatDays: [String] = []
    @State private var selectedSound = "Bell"
    
    let availableSounds = ["Bell", "Dream", "Pleasant"]

    @Environment(\.dismiss) var dismiss

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
            .navigationTitle("Add Alarm")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        alarmManager.addAlarm(time: selectedTime, repeatDays: repeatDays, sound: selectedSound)
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
