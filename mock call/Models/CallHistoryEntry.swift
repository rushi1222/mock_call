//
//  CallHistoryEntry.swift
//  mock call
//

import Foundation
import SwiftData

@Model
final class CallHistoryEntry {
    var id: UUID
    var callerName: String
    var startedAt: Date
    var durationSeconds: Int
    var wasAnswered: Bool

    init(
        id: UUID = UUID(),
        callerName: String,
        startedAt: Date = .now,
        durationSeconds: Int,
        wasAnswered: Bool
    ) {
        self.id = id
        self.callerName = callerName
        self.startedAt = startedAt
        self.durationSeconds = durationSeconds
        self.wasAnswered = wasAnswered
    }
}
