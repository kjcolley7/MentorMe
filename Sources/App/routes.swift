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
	
	// Example of configuring a controller
	let todoController = TodoController()
	router.get("todos", use: todoController.index)
	router.post("todos", use: todoController.create)
	router.delete("todos", Todo.parameter, use: todoController.delete)
}
