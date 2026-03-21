// ResonanceApp_iOS.swift
// Resonance — Design for the Exhale
//
// iPhone & iPad entry point.
// Adaptive layouts: tab bar on iPhone, sidebar + expanded views on iPad.

import SwiftUI

#if os(iOS)
@main
struct ResonanceApp_iOS: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // Theme is managed internally
        }
    }
}
#endif
