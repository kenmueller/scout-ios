import Foundation

let defaults = UserDefaults.standard

func handle(error: Error?, file: StaticString = #file, line: Int = #line) {
	guard let error = error else { return }
	print("Error at \(file):\(line) \"\(error)\"")
}
