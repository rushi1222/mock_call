//
//  HomeView.swift
//  mock call
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \CallerPreset.createdAt) private var presets: [CallerPreset]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPreset: CallerPreset?
    @State private var showingEditor = false

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(presets) { preset in
                        Button {
                            selectedPreset = preset
                        } label: {
                            PresetCard(preset: preset)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        showingEditor = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                            Text("Add Custom")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .navigationTitle("Mock Call")
            .onAppear(perform: seedBuiltInsIfNeeded)
            .sheet(item: $selectedPreset) { preset in
                TriggerSheetView(preset: preset)
            }
            .sheet(isPresented: $showingEditor) {
                PresetEditorView()
            }
        }
    }

    private func seedBuiltInsIfNeeded() {
        guard presets.isEmpty else { return }
        for builtIn in CallerPreset.builtIns {
            modelContext.insert(builtIn)
        }
    }
}

private struct PresetCard: View {
    let preset: CallerPreset

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: preset.symbolName)
                .font(.system(size: 36))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color(hex: preset.tintHex), in: Circle())
            Text(preset.name)
                .font(.headline)
            Text(preset.relationshipLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
    }
}
