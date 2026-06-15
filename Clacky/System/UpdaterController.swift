import SwiftUI
import Combine
import Sparkle

/// Owns the Sparkle updater and bridges its state into SwiftUI.
///
/// Why this matters for permissions: Sparkle replaces Clacky *in place* at its
/// existing install path. The new build carries the same Developer ID
/// Designated Requirement, so TCC keeps the user's granted **Accessibility**
/// permission — Clacky needs it to listen for keystrokes, and without in-place
/// updates every release would force the user to re-grant it. Downloading a
/// fresh DMG/ZIP and replacing the bundle by hand re-quarantines it and breaks
/// that association.
@MainActor
final class UpdaterController: ObservableObject {
    static let shared = UpdaterController()

    private let controller: SPUStandardUpdaterController

    /// Mirrors `SPUUpdater.canCheckForUpdates` so menu items can disable
    /// themselves while a check is already in flight.
    @Published private(set) var canCheckForUpdates = false

    var updater: SPUUpdater { controller.updater }

    private init() {
        // `startingUpdater: true` kicks off Sparkle's scheduled background
        // checks. On first launch Sparkle shows a one-time consent prompt
        // asking whether to enable automatic checks (no SUEnableAutomaticChecks
        // key is set in Info.plist, so the choice is left to the user).
        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        controller.updater
            .publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }

    /// Triggers a user-initiated update check (shows UI for "no updates", etc.).
    func checkForUpdates() {
        controller.updater.checkForUpdates()
    }

    /// Bound to the "Automatically check for updates" toggle in Settings.
    var automaticallyChecksForUpdates: Bool {
        get { controller.updater.automaticallyChecksForUpdates }
        set { controller.updater.automaticallyChecksForUpdates = newValue }
    }
}
