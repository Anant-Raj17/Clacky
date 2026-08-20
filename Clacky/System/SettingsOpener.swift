import AppKit

/// Opens the SwiftUI Settings scene from AppKit (reopen, no menu-bar extra, etc.).
enum SettingsOpener {
    static func open() {
        NSApp.activate(ignoringOtherApps: true)
        let selectors = ["showSettingsWindow:", "openSettings:"]
        for name in selectors {
            let selector = Selector(name)
            if NSApp.responds(to: selector) {
                NSApp.sendAction(selector, to: nil, from: nil)
                return
            }
        }
        for window in NSApp.windows where window.title.localizedCaseInsensitiveContains("settings") {
            window.makeKeyAndOrderFront(nil)
            return
        }
    }
}
