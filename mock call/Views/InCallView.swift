//
//  InCallView.swift
//  mock call
//
//  Custom fallback in-call screen (fallback mode only). Uses the same
//  tinted-avatar treatment as RingingView so the two screens feel like
//  one continuous call rather than two different UIs.
//

import SwiftUI

struct InCallView: View {
    @Environment(CallManager.self) private var callManager

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                Spacer().frame(height: 72)

                Text(caller?.name ?? "")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)

                Text(timeString)
                    .font(.system(size: 17, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 4)

                Spacer()

                avatar

                Text("Mock call — muted")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 16)

                Spacer()

                Button {
                    callManager.endActiveCall()
                } label: {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                        .frame(width: 76, height: 76)
                        .background(.red, in: Circle())
                }
                .padding(.bottom, 56)
            }
            .padding(.horizontal, 32)
        }
        .statusBarHidden()
    }

    private var caller: CallerInfo? {
        if case .active(let caller, _) = callManager.phase { return caller }
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

    private var timeString: String {
        let minutes = callManager.remainingSeconds / 60
        let seconds = callManager.remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    InCallView()
        .environment(CallManager())
}
