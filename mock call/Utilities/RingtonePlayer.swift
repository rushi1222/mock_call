//
//  RingtonePlayer.swift
//  mock call
//
//  Plays the ringtone with the audio session set to .playback, which is
//  what makes it audible even with the phone's silent switch on. CallKit
//  gives you this for free; our no-CallKit fallback (CallKit's real
//  incoming-call reporting needs a paid Apple Developer account) does it
//  manually instead.
//

import Foundation
import AVFoundation

@MainActor
final class RingtonePlayer {
    static let shared = RingtonePlayer()
    private var player: AVAudioPlayer?

    func startLooping() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, options: [])
            try session.setActive(true)

            guard let url = Bundle.main.url(forResource: "ringtone", withExtension: "wav") else {
                print("[trace] ringtone.wav not found in bundle")
                return
            }
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            print("[trace] RingtonePlayer failed to start: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
