// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
//
//let package = Package(
//	name: "ModernSwiftStorage",
//	platforms: [
//		.iOS(.v13),
//		.macOS(.v10_15),
//		.watchOS(.v6),
//		.tvOS(.v13)
//	],
//	products: [
//		.library(
//			name: "ModernSwiftStorage",
//			targets: ["ModernSwiftStorage"]
//		),
//	],
//	targets: [
//		.target(
//			name: "ModernSwiftStorage",
//			dependencies: []
//		)
//	]
//)


let package = Package(
	name: "ModernSwiftStorage",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.watchOS(.v6),
		.tvOS(.v13)
	],
	products: [
		.library(
			name: "ModernSwiftStorage",
			targets: ["ModernSwiftStorage"]),
	],
	targets: [
		.target(
			name: "ModernSwiftStorage",
			dependencies: []),
		.testTarget(
			name: "ModernSwiftStorageTests",
			dependencies: ["ModernSwiftStorage"]),
	]
)
