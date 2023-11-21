import ModelKit
import SwiftData

@SwiftDataModel
public struct MyModel {
	@Attribute(.unique) var name: String
	var number: Int
}

@SwiftDataModel
public struct NestedModelExample {
	@NestedModel var nested: MyModel
}
