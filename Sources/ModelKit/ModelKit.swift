@available(swift 5.9)
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
@attached(member, names: arbitrary)
public macro SwiftDataModellable() = #externalMacro(module: "ModelKitMacros", type: "SwiftDataModelMacro")
