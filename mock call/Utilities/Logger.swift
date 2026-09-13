//
//  Logger.swift
//  mock call
//
//  No-op analytics/crash logging for v1. Swap the implementation in
//  Phase 4 for a real SDK without touching any call site.
//

import Foundation

protocol AnalyticsLogging: Sendable {
    func log(event: String, properties: [String: String])
    func logError(_ error: Error)
}

struct NoOpAnalyticsLogger: AnalyticsLogging {
    func log(event: String, properties: [String: String] = [:]) {
        #if DEBUG
        print("[analytics] \(event) \(properties)")
        #endif
    }

    func logError(_ error: Error) {
        #if DEBUG
        print("[analytics] error: \(error.localizedDescription)")
        #endif
    }
}

enum Analytics {
    static let shared: AnalyticsLogging = NoOpAnalyticsLogger()
}
