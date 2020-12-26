import SwiftUI

struct JoinedView: View {
	@EnvironmentObject var game: Game
	
	var body: some View {
		VStack {
			Text("Players")
				.font(.system(size: 24, weight: .bold))
			VStack(spacing: 8) {
				if let users = game.users {
					HStack(spacing: 0) {
						Text(game.name)
						Text(" (you)")
							.opacity(0.7)
						Spacer(minLength: 8)
						Text(game.ready ? "Ready" : "Not ready")
							.font(.system(size: 16, weight: .bold))
							.foregroundColor(game.ready ? .green : .red)
					}
					ForEach(users) { user in
						HStack(spacing: 0) {
							Text(user.name)
							Spacer(minLength: 8)
							Text(user.ready ? "Ready" : "Not ready")
								.font(.system(size: 16, weight: .bold))
								.foregroundColor(user.ready ? .green : .red)
						}
					}
				} else {
					Text("Loading...")
				}
			}
			.padding(.vertical, 12)
			Button(action: game.toggleReady) {
				Text(game.ready ? "Ready" : "Not ready")
					.padding(.horizontal, 20)
					.padding(.vertical, 8)
					.font(.system(size: 16, weight: .bold))
					.background(game.ready ? Color.green : Color.red)
					.cornerRadius(8)
			}
			.disabled(game.users == nil)
			.opacity(game.users == nil ? 0.7 : 1)
		}
	}
}

struct JoinedView_Previews: PreviewProvider {
	static var previews: some View {
		JoinedView()
			.environmentObject(Game())
	}
}
