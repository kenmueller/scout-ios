import Foundation

struct User: Decodable, Identifiable {
	struct Init: Encodable {
		let `init` = true
		let id: UUID
		let name: String
	}
	
	struct Ready: Encodable {
		let ready: Bool
		
		init(_ ready: Bool) {
			self.ready = ready
		}
	}
	
	struct Ping: Encodable {
		let ping = true
		let id: UUID
	}
	
	struct Find: Encodable {
		let find = true
		let id: UUID
	}
	
	struct Pinged: Decodable {
		let pinged: Bool
	}
	
	struct Found: Decodable {
		let found: Bool
	}
	
	struct Users: Decodable {
		let users: [User]
	}
	
	static let NAME_KEY = "name"
	static let DEFAULT_NAME = ""
	
	let id: UUID
	let name: String
	let ready: Bool
	let pinged: Bool
	let found: Bool
}
