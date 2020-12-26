import SwiftUI

struct InitialView: View {
	@EnvironmentObject var game: Game
	
	var body: some View {
		VStack {
			Text("Scout: Hide and Seek")
				.font(.system(size: 24, weight: .bold))
			TextField("Name", text: $game.name)
				.padding(.horizontal, 8)
				.padding(.vertical, 4)
				.background(Color.white.opacity(0.1))
				.cornerRadius(8)
				.padding(.vertical, 12)
			Button(action: game.join) {
				Text("Next")
					.padding(.horizontal, 20)
					.padding(.vertical, 8)
					.font(.system(size: 16, weight: .bold))
					.background(Color(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)))
					.cornerRadius(8)
			}
			.disabled(game.name.isEmpty)
			.opacity(game.name.isEmpty ? 0.7 : 1)
		}
	}
}

struct InitialView_Previews: PreviewProvider {
	static var previews: some View {
		InitialView()
			.environmentObject(Game())
	}
}
