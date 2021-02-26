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
            targets: ["Research"]),
        .library(
            name: "ResearchUI",
            targets: ["ResearchUI"]),
        .library(
            name: "ResearchAudioRecorder",
            targets: ["ResearchAudioRecorder"]),
        .library(
            name: "ResearchMotion",
            targets: ["ResearchMotion"]),
        .library(
            name: "ResearchLocation",
            targets: ["ResearchLocation"]),
        .library(
            name: "Research_UnitTest",
            targets: ["Research_UnitTest", "NSLocaleSwizzle"]),

    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "JsonModel",
                 url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
                 "1.1.0"..<"1.2.0"),
    ],
    targets: [

        // Research is the main target included in this repo. The "Formatters" and
        // "ExceptionHandler" targets are developed in Obj-c so they require a
        // separate target.
        .target(
            name: "Research",
            dependencies: ["JsonModel",
                           "ExceptionHandler",
                           "Formatters",
            ],
            path: "Research/Research/",
            exclude: ["Info-iOS.plist",
                      "Core/README.md",
                      "DataModel/README.md",
            ]),
        .target(name: "ExceptionHandler",
                dependencies: [],
                path: "Research/ExceptionHandler/",
                exclude: ["Info.plist"]),
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

        // ResearchAudioRecorder is used to allow recording dbFS level.
        .target(
            name: "ResearchAudioRecorder",
            dependencies: [
                "Research",
            ],
            path: "Research/ResearchAudioRecorder/",
            exclude: ["Info.plist"]),

        // ResearchMotion is used to allow recording motion sensors.
        .target(
            name: "ResearchMotion",
            dependencies: [
                "Research",
            ],
            path: "Research/ResearchMotion/",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources"),
            ]),

        // ResearchLocation is used to allow location authorization and record distance
        // travelled.
        .target(
            name: "ResearchLocation",
            dependencies: [
                "Research",
                "ResearchMotion",
            ],
            path: "Research/ResearchLocation/",
            exclude: ["Info.plist"]),
        
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
        .testTarget(
            name: "ResearchMotionTests",
            dependencies: [
                "ResearchMotion",
                "Research_UnitTest",
            ],
            path: "Research/ResearchMotionTests/",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "ResearchLocationTests",
            dependencies: [
                "ResearchLocation",
                "Research_UnitTest",
            ],
            path: "Research/ResearchLocationTests/",
            exclude: ["Info.plist"]),
        
    ]
)
