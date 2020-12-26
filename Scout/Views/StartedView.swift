import SwiftUI

struct StartedView: View {
	@EnvironmentObject var game: Game
	
	var body: some View {
		VStack {
			Text(
				game.isSeeker
					? "Seeker"
					: game.found ? "You've been found!" : "Hider"
			)
			.font(.title)
			.bold()
			.foregroundColor(game.isSeeker ? .red : .green)
			if let seconds = game.countdownSecondsRemaining {
				Text(String(seconds))
					.font(.largeTitle)
					.bold()
					.padding(.top, 16)
			} else {
				VStack(spacing: 8) {
					if let users = game.users {
						if !game.isSeeker {
							if let seeker = game.seeker {
								HStack(spacing: 0) {
									Text(seeker.name)
									Spacer(minLength: 8)
									Text("Seeker")
										.bold()
										.foregroundColor(.red)
								}
							}
							HStack(spacing: 0) {
								Text(game.name)
								Text(" (you)")
									.opacity(0.7)
								Spacer(minLength: 8)
								Text(game.found ? "Found" : "Hidden")
									.bold()
									.foregroundColor(game.found ? .red : .green)
							}
						}
						ForEach(game.isSeeker ? users : users.filter(game.isHider)) { user in
							HStack(spacing: 0) {
								Text(user.name)
								Spacer(minLength: 8)
								HStack {
									if game.isSeeker && !user.pinged && !user.found {
										Button { self.game.ping(user) } label: {
											Text("Ping")
												.bold()
												.padding(.horizontal, 10)
												.padding(.vertical, 4)
												.background(Color(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)))
												.cornerRadius(8)
										}
									}
									if game.isSeeker && !user.found {
										Button { self.game.find(user) } label: {
											Text("Mark as found")
												.bold()
												.padding(.horizontal, 10)
												.padding(.vertical, 4)
												.background(Color.red)
												.cornerRadius(8)
										}
									} else {
										Text(user.found ? "Found" : "Hidden")
											.bold()
											.foregroundColor(
												(game.isSeeker ? !user.found : user.found) ? .red : .green
											)
									}
								}
							}
						}
					} else {
						Text("Loading...")
					}
				}
				.padding(.top, 12)
			}
		}
	}
}

struct StartedView_Previews: PreviewProvider {
	static var previews: some View {
		StartedView()
			.environmentObject(Game())
	}
}
