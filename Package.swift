// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SideMenuTransition",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(
            name: "SideMenuTransition",
            targets: ["SideMenuTransition"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble", from: "9.0.0"),
        .package(url: "https://github.com/Quick/Quick", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "SideMenuTransition",
            dependencies: []
        ),
        .testTarget(
            name: "SideMenuTransitionTests",
            dependencies: ["SideMenuTransition", "Quick", "Nimble"]
        )
    ]
)
