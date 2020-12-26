import Foundation
import Combine

final class Game: ObservableObject {
	struct Start: Decodable {
		let seeker: UUID
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
			sendReady()
		}
	}
	
	@Published private(set) var users: [User]?
	@Published private(set) var seeker: UUID?
	
	private var task: URLSessionWebSocketTask?
	
	deinit {
		leave()
	}
	
	var isSeeker: Bool {
		id == seeker
	}
	
	func join() {
		guard task == nil, let url = URL(string: API_URL) else { return }
		
		state = .joined
		ready = false
		
		task = URLSession.shared.webSocketTask(with: url)
		
		task?.receive(completionHandler: onReceive)
		task?.resume()
		
		sendInit()
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
		} else if let seeker = try? decoder.decode(Start.self, from: data).seeker {
			DispatchQueue.main.async {
				self.state = .started
				self.seeker = seeker
			}
		}
	}
	
	func send(_ data: Data) {
		task?.send(.data(data)) { error in
			guard let error = error else { return }
			print(error)
		}
	}
	
	func sendInit() {
		(try? encoder.encode(User.Init(id: id, name: name))).map(send)
	}
	
	func sendReady() {
		(try? encoder.encode(User.Ready(ready))).map(send)
	}
}
