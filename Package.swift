// swift-tools-version:4.0
import PackageDescription

let package = Package(
	name: "MentorMe",
	dependencies: [
		// 💧 A server-side Swift web framework.
		.package(url: "https://github.com/vapor/vapor.git", .exact("3.0.0-rc.2.6")),
		
		// 🖋🐬 Swift ORM (queries, models, relations, etc) built on MySQL.
		.package(url: "https://github.com/vapor/fluent-mysql.git", .exact("3.0.0-rc.2.3")),
		
		// 🍃 An expressive, performant, and extensible templating language built for Swift.
		.package(url: "https://github.com/vapor/leaf.git", .exact("3.0.0-rc.2")),
		
		// 👤 Authentication and Authorization layer for Fluent.
		.package(url: "https://github.com/vapor/auth.git", .exact("2.0.0-rc.3.1")),
		
		// ⚡️Non-blocking, event-driven Redis client.
		.package(url: "https://github.com/vapor/redis.git", .exact("3.0.0-rc.2.3")),
		
		// 🚍 High-performance trie-node router.
		.package(url: "https://github.com/vapor/routing.git", .exact("3.0.0-rc.2"))
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

