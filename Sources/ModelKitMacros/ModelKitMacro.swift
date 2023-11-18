import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SwiftDataModelMacro {}

extension SwiftDataModelMacro: MemberMacro {
	public enum Error: Swift.Error {
		case unsupported
	}

	public static func expansion(of node: AttributeSyntax,
								 providingMembersOf declaration: some DeclGroupSyntax,
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


		[
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
		[
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

	private static func swiftDataModelVarDecl(modifiers: DeclModifierListSyntax, memberBlock: MemberBlockSyntax) -> VariableDeclSyntax {
		let variableDecls = memberBlock.members
			.compactMap { $0.decl.as(VariableDeclSyntax.self) }
			.filter { !$0.modifiers.contains { $0.name.text == "static" } }

		return VariableDeclSyntax(modifiers: modifiers, bindingSpecifier: .keyword(.var)) {
			PatternBindingSyntax(
				pattern: IdentifierPatternSyntax(identifier: .identifier("swiftData")),
				typeAnnotation: TypeAnnotationSyntax(
					type: IdentifierTypeSyntax(name: .identifier("SwiftDataModel"))
				),
				accessorBlock: swiftDataModelVarDeclAccessorBlock(variableDecls: variableDecls)
			)
		}
	}

	private static func swiftDataModelVarDeclAccessorBlock(variableDecls: [VariableDeclSyntax]) -> AccessorBlockSyntax {
		return AccessorBlockSyntax(
			accessors: .getter(
				CodeBlockItemListSyntax {
					CodeBlockItemSyntax(
						item: .expr(
							ExprSyntax(
								FunctionCallExprSyntax(
									calledExpression: DeclReferenceExprSyntax(baseName: .identifier("SwiftDataModel")),
									leftParen: .leftParenToken(),
									arguments: LabeledExprListSyntax {
										for decl in variableDecls {
											if let name = decl.bindings.first?.pattern {
												LabeledExprSyntax(
													label: name.description,
													expression: DeclReferenceExprSyntax(baseName: .identifier(name.description))
												)
											}
										}
									},
									rightParen: .rightParenToken()
								)
							)
						)
					)
				}
			)
		)
	}

	private static func swiftDataModelDecl(modifiers: DeclModifierListSyntax, memberBlock: MemberBlockSyntax) -> ClassDeclSyntax {
		let variableDecls = memberBlock.members
			.compactMap { $0.decl.as(VariableDeclSyntax.self) }
			.filter { !$0.modifiers.contains { $0.name.text == "static" } }

		let modelAttribute = AttributeSyntax(
			attributeName: IdentifierTypeSyntax(
				name: .identifier("Model")
			)
		)

		return ClassDeclSyntax(
			attributes: AttributeListSyntax { modelAttribute },
			modifiers: modifiers,
			name: .identifier("SwiftDataModel"),
			memberBlock: MemberBlockSyntax(
				members: MemberBlockItemListSyntax {
					for decl in variableDecls {
						MemberBlockItemSyntax(decl: decl)
					}
					MemberBlockItemSyntax(
						decl: InitializerDeclSyntax(
							modifiers: modifiers,
							signature: FunctionSignatureSyntax(
								parameterClause: FunctionParameterClauseSyntax(
									parameters: FunctionParameterListSyntax {
										for decl in variableDecls {
											if let name = decl.bindings.first?.pattern, let type = decl.bindings.first?.typeAnnotation?.type {
												FunctionParameterSyntax(firstName: .identifier(name.description), type: type)
											}
										}
									}
								)
							),
							body: CodeBlockSyntax {
								for decl in variableDecls {
									if let name = decl.bindings.first?.pattern {
										ExprSyntax("self.\(raw: name.description) = \(raw: name.description)")
									}
								}
							}
						)
					)
				}
			)
		)
	}
}

@main
struct ModelKitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SwiftDataModelMacro.self,
    ]
}
