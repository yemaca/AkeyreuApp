//
//  AlarmListView.swift
//  Akeyreu
//
//  Created by Asher Amey on 1/22/25.
//

import SwiftUI

struct AlarmListView: View {
    @StateObject private var alarmManager = AlarmManager()
    @State private var showingAddAlarmScreen = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(alarmManager.alarms.indices, id: \.self) { index in
                        AlarmRow(alarm: $alarmManager.alarms[index])
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { alarmManager.removeAlarm(at: $0) }
                    }
                }
                .listStyle(PlainListStyle())

                Button(action: {
                    showingAddAlarmScreen = true
                }) {
                    Text("Add Alarm")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Alarms")
            .sheet(isPresented: $showingAddAlarmScreen) {
                AddAlarmView(alarmManager: alarmManager)
            }
        }
    }
}

struct AlarmRow: View {
    @Binding var alarm: Alarm

    var body: some View {
        HStack {
            Text(alarm.time, style: .time)
                .font(.headline)
            Spacer()
            Toggle("", isOn: $alarm.isEnabled)
        }
        .padding()
    }
}
