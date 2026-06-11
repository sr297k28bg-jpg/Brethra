import SwiftUI

@main
struct BrethraApp: App {
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .environmentObject(settings)
        }
    }
}
