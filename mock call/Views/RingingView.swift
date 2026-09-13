//
//  RingingView.swift
//  mock call
//
//  Custom fallback ringing screen shown when AppConfig.useRealCallKit
//  is false (no paid Apple Developer account). Styled to resemble the
//  real iOS incoming-call screen: name pinned near the top with a
//  small "mobile" subtitle, a tinted avatar using the preset's own
//  color/symbol, a soft gradient background, and wide bottom-pinned
//  decline/accept buttons.
//

import SwiftUI

struct RingingView: View {
    @Environment(CallManager.self) private var callManager

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                Spacer().frame(height: 72)

                Text(caller?.name ?? "")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)

                Text("mobile")
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 4)

                Spacer()

                avatar

                Spacer()

                buttonRow
                    .padding(.bottom, 56)
            }
            .padding(.horizontal, 32)
        }
        .statusBarHidden()
    }

    private var caller: CallerInfo? {
        if case .ringing(let caller) = callManager.phase { return caller }
        return nil
    }

    private var tint: Color {
        Color(hex: caller?.tintHex ?? "8E8E93")
    }

    private var backgroundGradient: some View {
        RadialGradient(
            colors: [tint.opacity(0.55), Color.black.opacity(0.96)],
            center: .top,
            startRadius: 40,
            endRadius: 520
        )
        .background(Color.black)
        .ignoresSafeArea()
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.9))
                .frame(width: 132, height: 132)
            Image(systemName: caller?.symbolName ?? "person.fill")
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(.white)
        }
        .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
    }

    private var buttonRow: some View {
        HStack {
            callButton(system: "phone.down.fill", tint: .red, label: "Decline") {
                callManager.declineFallbackCall()
            }
            Spacer()
            callButton(system: "phone.fill", tint: .green, label: "Accept") {
                callManager.answerFallbackCall()
            }
        }
    }

    private func callButton(system: String, tint: Color, label: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 12) {
            Button(action: action) {
                Image(systemName: system)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .frame(width: 76, height: 76)
                    .background(tint, in: Circle())
            }
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.85))
        }
    }
}

#Preview {
    RingingView()
        .environment(CallManager())
}
