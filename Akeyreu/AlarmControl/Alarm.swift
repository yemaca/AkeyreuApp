//
//  Alarm.swift
//  Akeyreu
//
//  Created by Asher Amey on 1/22/25.
//

import Foundation

struct Alarm: Identifiable, Codable {
    let id: UUID
    var time: Date
    var isEnabled: Bool
    var repeatDays: [String]
    var sound: String

    init(id: UUID = UUID(), time: Date, isEnabled: Bool, repeatDays: [String], sound: String) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
        self.sound = sound
    }
}
