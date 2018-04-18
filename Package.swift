// swift-tools-version:4.0
import PackageDescription

let package = Package(
	name: "MentorMe",
	dependencies: [
		// 💧 A server-side Swift web framework.
		.package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc.2.6"),
		
		// 🖋🐬 Swift ORM (queries, models, relations, etc) built on MySQL.
		.package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0-rc.2.3"),
		
		// 🍃 An expressive, performant, and extensible templating language built for Swift.
		.package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc.2"),
		
		// 👤 Authentication and Authorization layer for Fluent.
		.package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc.3.1"),
		
		// ⚡️Non-blocking, event-driven Redis client.
		.package(url: "https://github.com/vapor/redis.git", from: "3.0.0-rc.2.3")
	],
	targets: [
		.target(name: "App", dependencies: [
			"Vapor",
			"FluentMySQL",
			"Leaf",
			"Authentication",
			"Redis"
		]),
		.target(name: "Run", dependencies: ["App"]),
		.testTarget(name: "AppTests", dependencies: ["App"])
	]
)

