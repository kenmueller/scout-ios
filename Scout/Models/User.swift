import Foundation

struct User: Decodable, Identifiable {
	struct Init: Encodable {
		let id: UUID
		let name: String
	}
	
	struct Ready: Encodable {
		let ready: Bool
		
		init(_ ready: Bool) {
			self.ready = ready
		}
	}
	
	struct Users: Decodable {
		let users: [User]
	}
	
	static let NAME_KEY = "name"
	static let DEFAULT_NAME = ""
	
	let id: UUID
	let name: String
	let ready: Bool
	let found: Bool
}
