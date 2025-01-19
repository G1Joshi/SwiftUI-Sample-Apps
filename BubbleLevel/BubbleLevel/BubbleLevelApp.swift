import SwiftUI

@main
struct BubbleLevelApp: App {
    @StateObject private var motionDetector = MotionDetector(updateInterval: 0.01)

    var body: some Scene {
        WindowGroup {
            LevelView()
                .environmentObject(motionDetector)
        }
    }
}
