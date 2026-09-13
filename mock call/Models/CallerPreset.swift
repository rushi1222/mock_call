//
//  CallerPreset.swift
//  mock call
//

import Foundation
import SwiftData

@Model
final class CallerPreset {
    var id: UUID
    var name: String
    var relationshipLabel: String
    var symbolName: String
    var tintHex: String
    var ringtoneID: String
    var isBuiltIn: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        relationshipLabel: String,
        symbolName: String = "person.crop.circle.fill",
        tintHex: String = "D85A38",
        ringtoneID: String = "default",
        isBuiltIn: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.relationshipLabel = relationshipLabel
        self.symbolName = symbolName
        self.tintHex = tintHex
        self.ringtoneID = ringtoneID
        self.isBuiltIn = isBuiltIn
        self.createdAt = createdAt
    }

    static var builtIns: [CallerPreset] {
        [
            CallerPreset(name: "Mom", relationshipLabel: "Mom", symbolName: "person.crop.circle.fill", tintHex: "D85A38", isBuiltIn: true),
            CallerPreset(name: "Dad", relationshipLabel: "Dad", symbolName: "person.crop.circle.fill", tintHex: "2E6A5E", isBuiltIn: true),
            CallerPreset(name: "Honey", relationshipLabel: "Honey", symbolName: "heart.circle.fill", tintHex: "C2447A", isBuiltIn: true)
        ]
    }
}
