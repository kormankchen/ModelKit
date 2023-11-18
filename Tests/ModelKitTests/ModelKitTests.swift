import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ModelKitMacros)
import ModelKitMacros

let testMacros: [String: Macro.Type] = [
	"SwiftDataModellable": SwiftDataModelMacro.self
]
#endif

final class ModelKitTests: XCTestCase {
	func test_swiftDataModellable() throws {
		#if canImport(ModelKitMacros)
		assertMacroExpansion(
			#"""
			@SwiftDataModellable
			struct MyModel {
				var name: String
				var number: Int
			}
			"""#,
			expandedSource:
				#"""
				struct MyModel {
					var name: String
					var number: Int

					@Model class SwiftDataModel {
						var name: String
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
				"""#,
			macros: testMacros,
			indentationWidth: .tabs(1)
		)
		#else
		throw XCTSkip("macros are only supported when running tests for the host platform")
		#endif
	}

	func test_swiftDataModellable_attributes() throws {
		#if canImport(ModelKitMacros)
		assertMacroExpansion(
			#"""
			@SwiftDataModellable
			struct MyModel {
				@Attribute(.unique) var name: String
				var number: Int
				static let text: String = ""
			}
			"""#,
		   expandedSource:
			#"""
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
			"""#,
		   macros: testMacros,
		   indentationWidth: .tabs(1)
		)
		#else
		throw XCTSkip("macros are only supported when running tests for the host platform")
		#endif
	}
}
