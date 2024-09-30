// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "HealthPlugin",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "HealthPlugin",
      targets: ["HealthPlugin"]),
  ],
  targets: [
    .target(
      name: "HealthPlugin",
      dependencies: ["Flutter"],
      path: "ios/Sources"
    ),
    .target(
      name: "Flutter",
      path: "SwiftFlutterShim"
    ),
  ]
)
