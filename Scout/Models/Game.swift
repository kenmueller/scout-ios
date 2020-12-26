import Foundation
import Combine
import Audio

final class Game: ObservableObject {
	struct Start: Decodable {
		let seeker: UUID
	}
	
	struct RestartRequest: Encodable {
		let restart = true
	}
	
	struct RestartResponse: Decodable {
		let restart: Bool
	}
	
	let id = UUID()
	
	@Published private(set) var state = State.initial
	
	@Published var name = defaults.string(forKey: User.NAME_KEY) ?? User.DEFAULT_NAME {
		didSet {
			defaults.set(name, forKey: User.NAME_KEY)
		}
	}
	@Published private(set) var ready = false {
		didSet {
			do {
				try sendReady()
			} catch {
				print(error)
			}
		}
	}
	@Published private(set) var found = false
	
	@Published private(set) var users: [User]?
	@Published private(set) var seekerId: UUID?
	
	@Published private(set) var countdownSecondsRemaining: Int?
	
	private var task: URLSessionWebSocketTask?
	
	deinit {
		leave()
	}
	
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
	
	func isHider(_ user: User) -> Bool {
		user.id != seekerId
	}
	
	func join() {
		guard task == nil, let url = URL(string: API_URL) else { return }
		
		state = .joined
		ready = false
		
		task = URLSession.shared.webSocketTask(with: url)
		
		task?.receive(completionHandler: onReceive)
		task?.resume()
		
		do {
			try sendInit()
		} catch {
			print(error)
		}
	}
	
	func leave() {
		task?.cancel()
		task = nil
		
		state = .initial
		ready = false
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
		do {
			try send(User.Ping(id: user.id))
		} catch {
			print(error)
		}
	}
	
	func find(_ user: User) {
		do {
			try send(User.Find(id: user.id))
		} catch {
			print(error)
		}
	}
	
	func restart() {
		do {
			try send(RestartRequest())
		} catch {
			print(error)
		}
	}
	
	func onRestart() {
		state = .joined
		ready = false
		found = false
	}
	
	func onReceive(_ result: Result<URLSessionWebSocketTask.Message, Error>) {
		switch result {
		case let .success(message):
			task?.receive(completionHandler: onReceive)
			onMessage(message)
		case let .failure(error):
			print(error)
		}
	}
	
	func onMessage(_ message: URLSessionWebSocketTask.Message) {
		guard case let .data(data) = message else {
			print("Invalid message")
			return
		}
		
		if let users = try? decoder.decode(User.Users.self, from: data).users {
			DispatchQueue.main.async { self.users = users }
		} else if let seekerId = try? decoder.decode(Start.self, from: data).seeker {
			DispatchQueue.main.async {
				self.state = .started
				self.seekerId = seekerId
				
				self.startCountdown()
			}
		} else if (try? decoder.decode(User.Pinged.self, from: data)) != nil {
			Audio.shared.play(fileNamed: "Ping.mp3")
		} else if (try? decoder.decode(User.Found.self, from: data)) != nil {
			DispatchQueue.main.async { self.found = true }
		} else if (try? decoder.decode(RestartResponse.self, from: data)) != nil {
			DispatchQueue.main.async(execute: onRestart)
		}
	}
	
	func send<Data: Encodable>(_ data: Data) throws {
		task?.send(.data(try encoder.encode(data))) { error in
			guard let error = error else { return }
			print(error)
		}
	}
	
	func sendInit() throws {
		try send(User.Init(id: id, name: name))
	}
	
	func sendReady() throws {
		try send(User.Ready(ready))
	}
}
