// swift-tools-version: 6.0

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
    .package(url: "https://github.com/apple/swift-system.git", from: "1.3.2"),
  ],
  targets: [
    .systemLibrary(
      name: "CBluray",
      pkgConfig: "libbluray",
      providers: [
        .brew(["libbluray"]),
      ]
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
        .product(name: "SystemPackage", package: "swift-system", condition: .when(platforms: [.linux])),
        .product(name: "Precondition", package: "Precondition"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
    .testTarget(
      name: "BlurayTests",
      dependencies: ["Bluray"]),
  ]
)
