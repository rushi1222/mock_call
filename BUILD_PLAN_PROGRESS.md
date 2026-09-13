# Mock Call — implementation progress

Implemented against the build plan artifact (Phase 0 + Phase 1: MVP core).
Written directly into the Xcode project by Claude on 2026-09-11.

## What's built

- **Config/AppConfig.swift** — single mock/live switch. `APIClientProtocol`
  + `MockAPIClient` (local fixtures) + `LiveAPIClient` (throws until Phase 4).
- **Models** — `CallerPreset` and `CallHistoryEntry` as SwiftData `@Model`s.
- **Auth** — `KeychainHelper` + `AuthManager`: mock login accepts any
  credentials, stores a fake token in Keychain.
- **CallKitService/CallManager.swift** — `CXProvider`/`CXProviderDelegate`
  wrapper: reports a fake incoming call, handles answer (starts a countdown
  timer) and end.
- **Views** — Login, Home (built-in Mom/Dad/Honey presets seeded on first
  run + custom preset creation), Preset editor (SF Symbol + color avatar,
  no photo picker yet), Trigger sheet (delay now/in N min, 30–35s default
  or custom duration), In-call screen (timer, muted, end button), History,
  Settings, and a one-time compliance disclosure sheet.
- **mock_callApp.swift** — wires up the SwiftData `ModelContainer` and
  injects `AuthManager` / `CallManager` via `.environment()`.

## Known gaps / what's NOT done yet

- **No xcconfig-based Mock/Staging/Prod schemes yet.** The plan's Phase 0
  calls for three `.xcconfig` files + matching schemes. Hand-editing the
  `.pbxproj` blindly (with no way to run `xcodebuild` from this session to
  verify it still opens) was too risky, so `AppConfig.useMockAPIs` is a
  single Swift constant for now. To add real schemes: Xcode → project file
  → Info tab → Configurations (duplicate Debug/Release into Mock/Staging/
  Prod), then Product → Scheme → New Scheme for each. Quick to do by hand,
  and safer there than scripted.
- **Delay-triggered calls only fire while the app stays open in the
  foreground** (a `DispatchQueue` timer). Reliable background/zero-tap
  firing (Lock Screen widget, Siri Shortcut, Action Button, `BGTaskScheduler`)
  is Phase 2 in the plan and isn't built yet.
- **No ringtone catalog UI, no history/settings polish beyond the basics,
  no onboarding beyond the compliance sheet** — Phase 3 items.
- **No StoreKit/paywall** — Phase 5, intentionally not started.
- **Avatar is an SF Symbol + color, not a real photo** — kept v1 simpler
  and avoided needing a Photos-library permission/Info.plist entry.

## Testing note

CallKit's incoming-call UI (lock screen takeover, ringing, Dynamic Island)
needs a **real device** — the Simulator does not reliably show it. Build to
your iPhone to actually see the ringing/answer flow work. The project
already has a development team set (`8V47H8F27K`), so it should just run.

## Next manual steps for you

1. Open the project in Xcode, let it index, and build to a real device.
2. If it doesn't compile, the most likely friction points are the
   `@Observable`/`@Environment(Type.self)` pattern (needs iOS 17+ — this
   project's deployment target is already far above that) and the CallKit
   delegate methods (they lean on this target's
   `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` setting, which was already
   on before this change).
3. Trigger a call from Home → tap Mom/Dad/Honey → Call Now, and confirm the
   system ringing screen appears, answering shows the in-call timer, and
   ending it logs a History entry.
