import MacroTesting
import ModelKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ModelKitTests: XCTestCase {
	override func invokeTest() {
		withMacroTesting(macros: [SwiftDataModelMacro.self]) {
			super.invokeTest()
		}
	}

	func test_swiftDataModellable() throws {
		assertMacro {
		  """
		  @SwiftDataModel
		  struct MyModel {
				var name: String
				var number: Int
				@NestedModel var nested: AnotherModel
		  }
		"""
		} expansion: {
			"""
			  
			  struct MyModel {
					var name: String
					var number: Int
					@NestedModel var nested: AnotherModel

			  @Model class SwiftDataModel {
			    var name: String
			    var number: Int
			    @NestedModel var nested: AnotherModel.SwiftDataModel
			    init(name: String, number: Int, nested: AnotherModel) {
			      self.name = name
			      self.number = number
			      self.nested = nested.swiftData
			    }
			  }

			  var swiftData: SwiftDataModel {
			    SwiftDataModel(name: name, number: number, nested: nested)
			  }
			  }
			"""
		}
	}

	func test_swiftDataModellable_attributes() throws {
		assertMacro {
		   """
		   @SwiftDataModel
		   struct MyModel {
		   @Attribute(.unique) var name: String
		   var number: Int
		   static let text: String = ""
		   }
		   """
		} expansion: {
			"""
			struct MyModel {
			@Attribute(.unique) var name: String
			var number: Int
			static let text: String = ""

			    @Model class SwiftDataModel {
			        @Attribute(.unique) var name: String
			        var number: Int
			        init(name: String, number: Int) {
			            self.name = name
			            self.number = number
			        }
			    }

			    var swiftData: SwiftDataModel {
			        SwiftDataModel(name: name, number: number)
			    }
			}
			"""
		}
	}
}
