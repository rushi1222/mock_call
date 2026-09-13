//
//  CallManager.swift
//  mock call
//
//  Two paths, chosen by AppConfig.useRealCallKit:
//
//  - Real CallKit (CXProvider/CXProviderDelegate): draws the actual
//    system ringing screen (lock screen takeover, Dynamic Island,
//    silent-mode override). Requires a paid Apple Developer Program
//    account — on a free Personal Team it gets silently rejected by the
//    system (the provider resets immediately, no error ever reaches the
//    reportNewIncomingCall completion handler).
//  - Fallback (default until that account exists): a custom full-screen
//    SwiftUI "ringing" view (see RingingView) plus a manually looped
//    ringtone whose audio session is set to .playback, which is what
//    makes it audible even with the silent switch on. No lock-screen
//    takeover or Dynamic Island, but works on any account, for free,
//    right now.
//
//  Delegate methods for the real-CallKit path rely on this target's
//  SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor / SWIFT_APPROACHABLE_CONCURRENCY
//  = YES build settings, and on CXProvider invoking its delegate on the
//  main queue (queue: nil below).
//

import Foundation
import CallKit
import AudioToolbox

/// Everything the ringing/in-call screens need to render — threaded
/// through CallPhase so those views can show the preset's actual color
/// and symbol instead of a generic placeholder avatar.
struct CallerInfo: Equatable {
    let name: String
    let symbolName: String
    let tintHex: String
}

enum CallPhase: Equatable {
    case idle
    case ringing(caller: CallerInfo)
    case active(caller: CallerInfo, totalDuration: Int)
    case ended
}

@MainActor
@Observable
final class CallManager: NSObject {
    private(set) var phase: CallPhase = .idle
    private(set) var remainingSeconds: Int = 0
    private(set) var lastErrorMessage: String?

    private let provider: CXProvider
    private let callController = CXCallController()
    private var activeCallUUID: UUID?
    private var timer: Timer?
    private var hapticTimer: Timer?
    private var totalDuration: Int = 30

    override init() {
        let configuration = CXProviderConfiguration()
        configuration.supportsVideo = false
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportedHandleTypes = [.generic]
        provider = CXProvider(configuration: configuration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    // MARK: - Entry point (routes to CallKit or the fallback)

    func startFakeIncomingCall(caller: CallerInfo, durationSeconds: Int) {
        totalDuration = durationSeconds
        if AppConfig.useRealCallKit {
            startViaCallKit(caller: caller)
        } else {
            startViaFallback(caller: caller)
        }
    }

    func endActiveCall() {
        if AppConfig.useRealCallKit {
            guard let uuid = activeCallUUID else { return }
            let endCallAction = CXEndCallAction(call: uuid)
            let transaction = CXTransaction(action: endCallAction)
            callController.request(transaction) { error in
                if let error { Analytics.shared.logError(error) }
            }
        } else {
            finishCall()
        }
    }

    func resetToIdle() {
        phase = .idle
        remainingSeconds = 0
    }

    func clearError() {
        lastErrorMessage = nil
    }

    // MARK: - Fallback path (no paid account required)

    private func startViaFallback(caller: CallerInfo) {
        print("[trace] fallback ringing started for \(caller.name)")
        phase = .ringing(caller: caller)
        RingtonePlayer.shared.startLooping()
        startRingHaptics()
    }

    func answerFallbackCall() {
        guard case .ringing(let caller) = phase else { return }
        print("[trace] fallback call answered")
        RingtonePlayer.shared.stop()
        stopRingHaptics()
        beginTimer(caller: caller)
    }

    func declineFallbackCall() {
        RingtonePlayer.shared.stop()
        stopRingHaptics()
        phase = .ended
    }

    private func startRingHaptics() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        hapticTimer?.invalidate()
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    private func stopRingHaptics() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    // MARK: - Real CallKit path (needs a paid Apple Developer account)

    private func startViaCallKit(caller: CallerInfo) {
        let callUUID = UUID()
        activeCallUUID = callUUID

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: caller.name)
        update.localizedCallerName = caller.name
        update.hasVideo = false
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false

        phase = .ringing(caller: caller)

        provider.reportNewIncomingCall(with: callUUID, update: update) { [weak self] error in
            guard let self else { return }
            if let error {
                Analytics.shared.logError(error)
                self.lastErrorMessage = "Couldn't start the call: \(error.localizedDescription)"
                self.phase = .idle
                self.activeCallUUID = nil
            }
        }
    }

    // MARK: - Shared timer

    private func beginTimer(caller: CallerInfo) {
        remainingSeconds = totalDuration
        phase = .active(caller: caller, totalDuration: totalDuration)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.remainingSeconds -= 1
            if self.remainingSeconds <= 0 {
                self.endActiveCall()
            }
        }
    }

    private func finishCall() {
        timer?.invalidate()
        timer = nil
        phase = .ended
        activeCallUUID = nil
    }
}

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        finishCall()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        if case .ringing(let caller) = phase {
            beginTimer(caller: caller)
        }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        finishCall()
        action.fulfill()
    }
}
