// swift-tools-version:5.1

import PackageDescription

let package = Package(
  
  name: "DirectToSwiftUI",
  
  platforms: [
    .macOS(.v10_15), .iOS(.v13)
  ],
  
  products: [
    .library(name: "NeoIRCClient", targets: [ "NeoIRCClient" ])
  ],
  
  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git",
             from: "2.17.0"),
    .package(url: "https://github.com/apple/swift-nio-transport-services",
             from: "1.5.1"),
    .package(url: "https://github.com/seaburg/IGIdenticon.git",
             from: "0.7.1"),
    .package(url: "https://github.com/NozeIO/swift-nio-irc-client.git",
             from: "0.7.1")
  ],
  
  targets: [
    .target(name: "NeoIRCClient", 
            dependencies: [ 
              "NIO", "IRC", "NIOTransportServices", "IGIdenticon" 
            ])
  ]
)
