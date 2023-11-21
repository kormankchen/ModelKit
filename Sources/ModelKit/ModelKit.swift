@available(swift 5.9)
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
@attached(member, names: arbitrary)
public macro SwiftDataModel() = #externalMacro(module: "ModelKitMacros", type: "SwiftDataModelMacro")

@available(swift 5.9)
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
@attached(peer)
public macro NestedModel() = #externalMacro(module: "ModelKitMacros", type: "NestedModelMacro")
