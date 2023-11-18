import ModelKit
import SwiftData

@SwiftDataModellable
struct MyModel {
	@Attribute(.unique) var name: String
	var number: Int
}
