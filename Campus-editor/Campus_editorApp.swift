import SwiftUI

@main
struct Campus_editorApp: App {
    @StateObject private var gamificationSystem = GamificationFacade(
        scheduleManager: ScheduleManager(),
        observer: PushNotificationService()
    )

    var body: some Scene {
        WindowGroup {
            ContentView(gamificationSystem: gamificationSystem)
        }
    }
}
