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
            }
            .navigationTitle("Add Alarm")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        alarmManager.addAlarm(time: selectedTime, repeatDays: repeatDays)
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
