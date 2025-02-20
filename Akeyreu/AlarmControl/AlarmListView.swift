//
//  AlarmListView.swift
//  Akeyreu
//
//  Created by Asher Amey on 1/22/25.
//

import SwiftUI

struct AlarmListView: View {
    @ObservedObject var alarmManager: AlarmManager
    @State private var selectedAlarmIndex: Int?

    var body: some View {
        NavigationView {
            List {
                ForEach(alarmManager.alarms.indices, id: \.self) { index in
                    NavigationLink(destination: EditAlarmView(alarmManager: alarmManager, alarmIndex: index)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(formattedTime(alarmManager.alarms[index].time))")
                                    .font(.headline)
                                Text(alarmManager.alarms[index].repeatDays.isEmpty ? "One-time alarm" : alarmManager.alarms[index].repeatDays.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { alarmManager.alarms[index].isEnabled },
                                set: { _ in alarmManager.toggleAlarm(at: index) }
                            ))
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        alarmManager.removeAlarm(at: index)
                    }
                }
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: AddAlarmView(alarmManager: alarmManager)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    // Format time for display
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
