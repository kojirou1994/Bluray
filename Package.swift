// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "Bluray",
  products: [
    .library(name: "Bluray", targets: ["Bluray"]),
    .executable(name: "bd-utility", targets: ["bd-utility"]),
  ],
  dependencies: [
    .package(url: "https://github.com/kojirou1994/Precondition.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
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
        .product(name: "Precondition", package: "Precondition"),
      ]),
    .executableTarget(
      name: "bd-utility",
      dependencies: [
        "Bluray",
        .product(name: "Precondition", package: "Precondition"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
    .testTarget(
      name: "BlurayTests",
      dependencies: ["Bluray"]),
  ]
)
