//
//  PresetEditorView.swift
//  mock call
//
//  V1 keeps the avatar to an SF Symbol + color instead of a real photo
//  picker, so no Photos-library permission/Info.plist key is needed yet.
//

import SwiftUI
import SwiftData

struct PresetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var relationshipLabel = ""
    @State private var symbolName = "person.crop.circle.fill"
    @State private var tintHex = "D85A38"

    private let symbolChoices = [
        "person.crop.circle.fill", "heart.circle.fill", "star.circle.fill",
        "briefcase.circle.fill", "graduationcap.circle.fill"
    ]
    private let colorChoices = ["D85A38", "2E6A5E", "C2447A", "3B6FA0", "8A5FBF"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    TextField("Relationship (e.g. Boss, Friend)", text: $relationshipLabel)
                }
                Section("Icon") {
                    HStack {
                        ForEach(symbolChoices, id: \.self) { symbol in
                            Image(systemName: symbol)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(symbol == symbolName ? Color.accentColor.opacity(0.2) : .clear, in: Circle())
                                .onTapGesture { symbolName = symbol }
                        }
                    }
                }
                Section("Color") {
                    HStack {
                        ForEach(colorChoices, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if hex == tintHex {
                                        Circle().stroke(.primary, lineWidth: 2)
                                    }
                                }
                                .onTapGesture { tintHex = hex }
                        }
                    }
                }
            }
            .navigationTitle("New Caller")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let preset = CallerPreset(
                            name: name,
                            relationshipLabel: relationshipLabel,
                            symbolName: symbolName,
                            tintHex: tintHex
                        )
                        modelContext.insert(preset)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
