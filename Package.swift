// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SageResearch",
    defaultLocalization: "en",
    platforms: [
        // Add support for all platforms starting from a specific version.
        .macOS(.v10_15),
        .iOS(.v11),
        .watchOS(.v4),
        .tvOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Research",
            targets: ["Research",
                      "Formatters",
            ]),
        .library(
            name: "ResearchUI",
            targets: ["ResearchUI"]),
        .library(
            name: "Research_UnitTest",
            targets: ["Research_UnitTest", "NSLocaleSwizzle"]),

    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "JsonModel",
                 url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
                 from: "1.3.4"),
        .package(name: "MobilePassiveData",
                 url: "https://github.com/Sage-Bionetworks/MobilePassiveData-SDK.git",
                 from: "1.2.1"),
    ],
    targets: [

        // Research is the main target included in this repo. The "Formatters"
        // target is developed in Obj-c so it requires a separate target.
        .target(
            name: "Research",
            dependencies: ["JsonModel",
                           "Formatters",
                           .product(name: "MobilePassiveData",
                                    package:  "MobilePassiveData"),
            ],
            path: "Research/Research/",
            exclude: ["Info-iOS.plist",
                      "Core/README.md",
                      "DataModel/README.md",
            ]),
        .target(name: "Formatters",
                dependencies: [],
                path: "Research/Formatters/",
                exclude: ["Info.plist"]),
        
        // ResearchUI currently only supports iOS devices. This includes views and view
        // controllers and references UIKit.
        .target(
            name: "ResearchUI",
            dependencies: [
                "Research",
            ],
            path: "Research/ResearchUI/",
            exclude: ["Info-iOS.plist"],
            resources: [
                .process("PlatformContext/Resources"),
                .process("iOS/Resources"),
            ]),
        
        // The following targets are set up for unit testing.
        .target(
            name: "Research_UnitTest",
            dependencies: ["Research",
                           "ResearchUI",
            ],
            path: "Research/Research_UnitTest/",
            exclude: ["Info.plist"]),
        .target(name: "NSLocaleSwizzle",
                dependencies: [],
                path: "Research/NSLocaleSwizzle/",
                exclude: ["Info.plist"]),
        .testTarget(
            name: "ResearchTests",
            dependencies: [
                "Research",
                "Research_UnitTest",
                "NSLocaleSwizzle",
            ],
            path: "Research/ResearchTests/",
            exclude: ["Info-iOS.plist"],
            resources: [
                .process("Resources"),
            ]),
        .testTarget(
            name: "ResearchUITests",
            dependencies: ["ResearchUI"],
            path: "Research/ResearchUITests/",
            exclude: ["Info.plist"]),
        
    ]
)
