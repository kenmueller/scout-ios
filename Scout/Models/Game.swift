import Foundation
import Combine
import Socket
import Audio

final class Game: ObservableObject {
	struct Query: SocketQuery {
		let id: UUID
		let name: String
	}
	
	struct Start: SocketMessage {
		static let id = "start"
		
		let seeker: UUID
	}
	
	struct Restart: SocketMessage {
		static let id = "restart"
	}
	
	struct Ready: SocketMessage {
		static let id = "ready"
		
		let ready: Bool
	}
	
	struct Ping: SocketMessage {
		static let id = "ping"
		
		let id: UUID
	}
	
	struct Pinged: SocketMessage {
		static let id = "pinged"
	}
	
	struct Find: SocketMessage {
		static let id = "find"
		
		let id: UUID
	}
	
	struct Found: SocketMessage {
		static let id = "found"
	}
	
	struct Users: SocketMessage {
		static let id = "users"
		
		let users: [User]
	}
	
	let id = UUID()
	let socket = Socket(url: URL(string: API_URL)!)
	
	@Published private(set) var state = State.initial
	
	@Published var name = defaults.string(forKey: User.NAME_KEY) ?? User.DEFAULT_NAME {
		didSet {
			defaults.set(name, forKey: User.NAME_KEY)
		}
	}
	@Published private(set) var ready = false {
		didSet {
			guard socket.isConnected else { return }
			
			socket.send(Ready(ready: ready)) {
				handle(error: $0)
			}
		}
	}
	@Published private(set) var found = false
	
	@Published private(set) var users: [User]?
	@Published private(set) var seekerId: UUID?
	
	@Published private(set) var countdownSecondsRemaining: Int?
	
	var isSeeker: Bool {
		id == seekerId
	}
	
	var seeker: User? {
		guard let id = seekerId else { return nil }
		return users?.first { $0.id == id }
	}
	
	var canRestart: Bool {
		isSeeker && users?.allSatisfy(\.found) ?? false
	}
	
	init() {
		socket.on { (users: Users) in
			self.users = users.users
		}
		
		socket.on { (start: Start) in
			self.state = .started
			self.seekerId = start.seeker
			
			self.startCountdown()
		}
		
		socket.on { (_: Pinged) in
			Audio.shared.play(fileNamed: "Ping.mp3")
		}
		
		socket.on { (_: Found) in
			self.found = true
		}
		
		socket.on { (_: Restart) in
			self.state = .joined
			self.ready = false
			self.found = false
		}
	}
	
	deinit {
		disconnect()
	}
	
	func isHider(_ user: User) -> Bool {
		user.id != seekerId
	}
	
	func connect() {
		do {
			state = .joined
			ready = false
			
			try socket.connect(query: Query(id: id, name: name))
		} catch {
			handle(error: error)
		}
	}
	
	func disconnect() {
		state = .initial
		ready = false
		
		socket.disconnect()
	}
	
	func toggleReady() {
		ready = !ready
	}
	
	func startCountdown() {
		countdownSecondsRemaining = COUNTDOWN_TIME
		var timer: Timer?
		
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			guard let self = self else {
				timer?.invalidate()
				return
			}
			
			self.countdownSecondsRemaining? -= 1
			
			guard self.countdownSecondsRemaining ?? 0 > 0 else {
				timer?.invalidate()
				self.countdownSecondsRemaining = nil
				
				if self.isSeeker {
					Audio.shared.play(fileNamed: "Start.mp3")
				}
				
				return
			}
		}
	}
	
	func ping(_ user: User) {
		guard socket.isConnected else { return }
		
		socket.send(Ping(id: user.id)) {
			handle(error: $0)
		}
	}
	
	func find(_ user: User) {
		guard socket.isConnected else { return }
		
		socket.send(Find(id: user.id)) {
			handle(error: $0)
		}
	}
	
	func restart() {
		guard socket.isConnected else { return }
		
		socket.send(Restart()) {
			handle(error: $0)
		}
	}
}
