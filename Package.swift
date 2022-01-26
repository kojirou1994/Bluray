// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "Bluray",
  products: [
    .library(
      name: "Bluray",
      targets: ["Bluray"]),
  ],
  dependencies: [
    .package(url: "https://github.com/kojirou1994/Precondition.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.3.0"),
  ],
  targets: [
    .systemLibrary(
      name: "CBluray",
      pkgConfig: "libbluray"
    ),
    .target(
      name: "Bluray",
      dependencies: [
        "CBluray",
        "Precondition",
      ]),
    .executableTarget(
      name: "bd-utility",
      dependencies: [
        "Bluray",
        "Precondition",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
    .testTarget(
      name: "BlurayTests",
      dependencies: ["Bluray"]),
  ]
)
