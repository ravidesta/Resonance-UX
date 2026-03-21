// HauteLumiereVisionApp.swift
// Haute Lumière — Vision Pro Immersive Experience

import SwiftUI

@main
struct HauteLumiereVisionApp: App {
    var body: some Scene {
        WindowGroup {
            VisionHomeView()
        }

        // In production: ImmersiveSpace for meditation environments
        // ImmersiveSpace(id: "meditationSpace") {
        //     ImmersiveMeditationView()
        // }
    }
}
