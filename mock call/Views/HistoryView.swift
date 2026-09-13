//
//  HistoryView.swift
//  mock call
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \CallHistoryEntry.startedAt, order: .reverse) private var history: [CallHistoryEntry]

    var body: some View {
        NavigationStack {
            Group {
                if history.isEmpty {
                    ContentUnavailableView(
                        "No calls yet",
                        systemImage: "clock",
                        description: Text("Calls you trigger will show up here.")
                    )
                } else {
                    List(history) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.callerName).font(.headline)
                            (Text(entry.startedAt, style: .date) + Text(" · \(entry.durationSeconds)s"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}
