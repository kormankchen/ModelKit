import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension Array {
	func filterOut(_ isNotIncluded: KeyPath<Element, Bool>) -> Self {
		filter {
			$0[keyPath: isNotIncluded] == false
		}
	}
}

extension DeclModifierSyntax {
	var isNeededAccessLevelModifier: Bool {
		switch name.tokenKind {
		case .keyword(.public): return true
		case .keyword(.package): return true
		default: return false
		}
	}
}

extension AttributeListSyntax.Element {
	private static let nestedModelAttribute = "@NestedModel"

	var hasNestedModel: Bool {
		switch self {
		case let .attribute(attribute):
			return attribute.trimmedDescription == Self.nestedModelAttribute
		default:
			return false
		}
	}
}

extension AttributeListSyntax {
	var hasNestedModel: Bool {
		filter(\.hasNestedModel).isEmpty == false
	}
}

extension DeclModifierSyntax {
	var isStatic: Bool {
		name.text.contains("static")
	}
}

extension VariableDeclSyntax {
	var isStatic: Bool {
		!modifiers.filter(\.isStatic).isEmpty
	}
}
