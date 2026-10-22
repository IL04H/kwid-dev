import SwiftUI

@main
struct KwidClockApp: App {
    var body: some Scene {
        WindowGroup { ClockHomeView().preferredColorScheme(.dark) }
    }
}
