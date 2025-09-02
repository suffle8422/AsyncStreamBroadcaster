// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncStreamBroadcaster",
    platforms: [.iOS(.v17)],
    dependencies: []
)

package.products = [
    .library(
        name: "AsyncStreamBroadcaster",
        targets: [.targetName]
    )
]

package.targets = [
    .target(name: .targetName),
    .testTarget(
        name: .testTargetName,
        dependencies: [
            .target(name: .targetName)
        ]
    )
]


private extension String {
    static let targetName = "AsyncStreamBroadcaster"
    static var testTargetName: String { "\(targetName)Tests" }
}
