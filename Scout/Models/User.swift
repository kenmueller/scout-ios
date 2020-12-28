import Foundation

struct User: Identifiable, Codable {
	static let NAME_KEY = "name"
	static let DEFAULT_NAME = ""
	
	let id: UUID
	let name: String
	let ready: Bool
	let pinged: Bool
	let found: Bool
}
