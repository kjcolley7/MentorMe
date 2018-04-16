import Routing
import Vapor
import FluentMySQL

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
	// Basic "Hello, world!" example
	router.get("hello") { req in
		return "Hello, world!"
	}
	
	// Dynamically look up the MySQL server version
	router.get("mysql-version") { req -> Future<String> in
		return req.withPooledConnection(to: .mysql) { conn in
			return conn.query("SELECT @@version AS v;", []).map(to: String.self) { rows in
				return try rows[0].firstValue(forColumn: "v")?.decode(String.self) ?? "n/a"
			}
		}
	}
	
	// Create /api/v1 routes
	let api = router.grouped("api", "v1")
	
	// List categories
	let categoryController = CategoryController()
	api.get("categories", use: categoryController.index)
	api.get("categories", Category.parameter, use: categoryController.get)
}
