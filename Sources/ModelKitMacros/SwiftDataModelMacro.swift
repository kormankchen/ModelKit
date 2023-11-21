import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SwiftDataModelMacro {
	static let modelAttribute = AttributeSyntax(
		attributeName: IdentifierTypeSyntax(
			name: .identifier("Model")
		)
	)
}

extension SwiftDataModelMacro: MemberMacro {
	public enum Error: Swift.Error {
		case unsupported
	}


	public static func expansion<D: DeclGroupSyntax>(of node: AttributeSyntax,
													 providingMembersOf declaration: D,
													 in context: some MacroExpansionContext) throws -> [DeclSyntax] {

		switch declaration {
		case let structDecl as StructDeclSyntax:
			return try expansion(of: node, providingMembersOf: structDecl, in: context)
		case let classDecl as ClassDeclSyntax:
			return try expansion(of: node, providingMembersOf: classDecl, in: context)
		default:
			throw Error.unsupported
		}
	}

	private static func expansion(of node: AttributeSyntax,
								  providingMembersOf declaration: StructDeclSyntax,
								  in context: some MacroExpansionContext) throws -> [DeclSyntax] {


		try [
			DeclSyntax(
				swiftDataModelDecl(
					modifiers: declaration.modifiers,
					memberBlock: declaration.memberBlock
				)
			),
			DeclSyntax(
				swiftDataModelVarDecl(
					modifiers: declaration.modifiers,
					memberBlock: declaration.memberBlock
				)
			)
		]
	}

	private static func expansion(of node: AttributeSyntax,
								  providingMembersOf declaration: ClassDeclSyntax,
								  in context: some MacroExpansionContext) throws -> [DeclSyntax] {
		try [
			DeclSyntax(
				swiftDataModelDecl(
					modifiers: declaration.modifiers,
					memberBlock: declaration.memberBlock
				)
			),
			DeclSyntax(
				swiftDataModelVarDecl(
					modifiers: declaration.modifiers,
					memberBlock: declaration.memberBlock
				)
			)
		]
	}

	private static func swiftDataModelVarDecl(modifiers: DeclModifierListSyntax,
											  memberBlock: MemberBlockSyntax) -> DeclSyntax {
		let variableDecls: [VariableDeclSyntax] = memberBlock.members
			.compactMap { $0.decl.as(VariableDeclSyntax.self) }
			.filterOut(\.isStatic)
		let accessLevel = modifiers.filter(\.isNeededAccessLevelModifier)
		let args = variableDecls
			.compactMap(\.bindings.first?.pattern.trimmedDescription)
			.map { "\($0): \($0)" }
			.joined(separator: ", ")
		return """
		\(raw: accessLevel)var swiftData: SwiftDataModel {
		SwiftDataModel(\(raw: args))
		}
		"""
	}

	private static func swiftDataModelDecl(modifiers: DeclModifierListSyntax, memberBlock: MemberBlockSyntax) throws -> DeclSyntax {
		let variableDecls: [VariableDeclSyntax] = memberBlock.members
			.compactMap { $0.decl.as(VariableDeclSyntax.self) }
			.filterOut(\.isStatic)
		let normalDecls = variableDecls.filterOut(\.attributes.hasNestedModel)
		let nestedModelDecls = variableDecls.filter(\.attributes.hasNestedModel)

		let declString = (normalDecls
			.map(\.trimmedDescription) + nestedModelDecls.map(\.trimmedDescription).map { "\($0).SwiftDataModel" }).joined(separator: "\n")
		let accessLevel = modifiers.filter(\.isNeededAccessLevelModifier)
		let initializerParams = variableDecls.compactMap(\.bindings.first?.trimmedDescription).joined(separator: ", ")
		let normalAssignments = normalDecls
			.compactMap(\.bindings.first?.pattern.trimmedDescription)
			.map { "self.\($0) = \($0)" }
		let nestedAssignments = nestedModelDecls
			.compactMap(\.bindings.first?.pattern.trimmedDescription)
			.map { "self.\($0) = \($0).swiftData" }
		let assignments = (normalAssignments + nestedAssignments).joined(separator: "\n")

		return """
		\(raw: Self.modelAttribute) \(raw:accessLevel)class SwiftDataModel {
		\(raw: declString)
		\(raw: accessLevel)init(\(raw: initializerParams)) {
		\(raw: assignments)
		}
		}
		"""
	}
}
