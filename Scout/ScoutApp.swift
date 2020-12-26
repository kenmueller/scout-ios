import SwiftUI

@main
struct ScoutApp: App {
	var body: some Scene {
		WindowGroup {
			RootView()
				.environmentObject(Game())
				.preferredColorScheme(.dark)
		}
	}
}
