import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ModelKitPlugin: CompilerPlugin {
	let providingMacros: [Macro.Type] = [
		SwiftDataModelMacro.self,
		NestedModelMacro.self
	]
}
