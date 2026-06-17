// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swiftui-scroll-edge-effect",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "ScrollEdgeEffect",
      targets: ["ScrollEdgeEffect"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/FluidGroup/swiftui-gaussian-linear-gradient",
      exact: "0.3.0"
    ),
  ],
  targets: [
    .target(
      name: "ScrollEdgeEffect",
      dependencies: [
        .product(
          name: "GaussianLinearGradient",
          package: "swiftui-gaussian-linear-gradient"
        ),
      ]
    ),
    .testTarget(
      name: "ScrollEdgeEffectTests",
      dependencies: ["ScrollEdgeEffect"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
