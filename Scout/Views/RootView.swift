import SwiftUI

struct RootView: View {
	@EnvironmentObject var game: Game
	
	var body: some View {
		ZStack {
			Color.black
				.edgesIgnoringSafeArea(.all)
			Group {
				switch game.state {
				case .initial: InitialView()
				case .joined: JoinedView()
				case .started: StartedView()
				}
			}
			.padding()
			.foregroundColor(.white)
		}
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView()
			.environmentObject(Game())
	}
}
