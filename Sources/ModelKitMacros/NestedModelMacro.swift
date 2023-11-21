import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NestedModelMacro: PeerMacro {
	public enum Error: Swift.Error {
		case misisngBinding
	}

	static let asAttribute = AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("NestedModel")))

	public static func expansion(of node: AttributeSyntax,
								 providingPeersOf declaration: some DeclSyntaxProtocol,
								 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
		[]
	}

	static func swiftDataMemberType(_ baseType: IdentifierTypeSyntax) -> MemberTypeSyntax {
		MemberTypeSyntax(baseType: baseType, name: .identifier("SwiftDataModel"))
	}

	static func swiftDataMemberTypeAnnotation(_ baseType: IdentifierTypeSyntax) -> TypeAnnotationSyntax {
		TypeAnnotationSyntax(type: swiftDataMemberType(baseType))
	}

	static func swiftDataMemberTypeAnnotation(_ baseTypeToken: TokenSyntax) -> TypeAnnotationSyntax {
		TypeAnnotationSyntax(type: swiftDataMemberType(.init(name: baseTypeToken)))
	}

	static func toSwiftDataVarDecl(_ decl: VariableDeclSyntax) -> VariableDeclSyntax {
		guard decl.attributes.contains(where: isNestedModelAttribute), let pattern = decl.bindings.first?.pattern else {
			return decl
		}

		return VariableDeclSyntax(
			attributes: decl.attributes,
			modifiers: decl.modifiers,
			bindingSpecifier: .keyword(.var),
			bindingsBuilder: {
				PatternBindingSyntax(
					pattern: pattern,
					typeAnnotation: NestedModelMacro.swiftDataMemberTypeAnnotation(.identifier(pattern.description))
				)
			}
		)
	}

	static func toExprSyntax(_ decl: VariableDeclSyntax) throws -> ExprSyntax {
		guard let name = decl.bindings.first?.pattern else { throw Error.misisngBinding }

		guard decl.attributes.contains(where: isNestedModelAttribute) else {
			return ExprSyntax("self.\(raw: name.description) = \(raw: name.description)")
		}
		return ExprSyntax("self.\(raw: name.description) = \(raw: name.description + ".swiftData")")
	}

	private static func isNestedModelAttribute(_ element: AttributeListSyntax.Element) -> Bool {
		switch element {
		case let .attribute(attribute):
			return attribute == NestedModelMacro.asAttribute
		default:
			return false
		}
	}
}
