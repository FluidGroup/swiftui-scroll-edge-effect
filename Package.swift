// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swiftui-scroll-edge-effect",
  platforms: [
    .iOS(.v18),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "ScrollEdgeEffect",
      targets: ["ScrollEdgeEffect"]
    ),
  ],
  targets: [
    .target(
      name: "ScrollEdgeEffect"
    ),
    .testTarget(
      name: "ScrollEdgeEffectTests",
      dependencies: ["ScrollEdgeEffect"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
