//
//  AlarmManager.swift
//  Akeyreu
//
//  Created by Asher Amey on 1/22/25.
//

import Foundation
import UserNotifications

class AlarmManager: ObservableObject {
    @Published var alarms: [Alarm] = [] {
        didSet {
            saveAlarms()
        }
    }

    init() {
        loadAlarms()
        requestNotificationPermission()
    }

    // Request notification permissions
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            } else if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }

    // Add a new alarm
    func addAlarm(time: Date, repeatDays: [String]) {
        let newAlarm = Alarm(time: time, isEnabled: true, repeatDays: repeatDays)
        alarms.append(newAlarm)
        scheduleNotification(for: newAlarm)
    }

    // Remove an alarm
    func removeAlarm(at index: Int) {
        let alarm = alarms[index]
        cancelNotification(for: alarm)
        alarms.remove(at: index)
    }

    // Toggle an alarm on/off
    func toggleAlarm(at index: Int) {
        alarms[index].isEnabled.toggle()
        if alarms[index].isEnabled {
            scheduleNotification(for: alarms[index])
        } else {
            cancelNotification(for: alarms[index])
        }
    }

    // Schedule a notification for an alarm
    func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Time to wake up!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell.mp3"))

        // Trigger for the alarm time
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // Create notification request
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)

        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(alarm.time).")
            }
        }
    }

    // Cancel a notification for an alarm
    func cancelNotification(for alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
        print("Notification canceled for alarm at \(alarm.time).")
    }

    // Save alarms to UserDefaults
    private func saveAlarms() {
        do {
            let data = try JSONEncoder().encode(alarms)
            UserDefaults.standard.set(data, forKey: "savedAlarms")
            print("Alarms saved successfully.")
        } catch {
            print("Failed to save alarms: \(error)")
        }
    }

    // Load alarms from UserDefaults
    private func loadAlarms() {
        guard let data = UserDefaults.standard.data(forKey: "savedAlarms") else { return }
        do {
            alarms = try JSONDecoder().decode([Alarm].self, from: data)
            print("Alarms loaded successfully.")
        } catch {
            print("Failed to load alarms: \(error)")
        }
    }
}
