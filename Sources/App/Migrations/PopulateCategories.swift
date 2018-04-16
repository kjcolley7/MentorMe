import FluentMySQL

final class PopulateCategories: Migration {
	typealias Database = MySQLDatabase
	
	static let categoryNames = [
		"Food and Drink",
		"Nature",
		"Art",
		"Sports",
		"Music",
		"Games",
		"Parties",
		"Other"
	]
	
	static func prepare(on connection: MySQLConnection) -> Future<Void> {
		// Insert all categories from categoryNames
		let futures = categoryNames.map { name in
			return Category(name: name).create(on: connection).map(to: Void.self) { _ in return }
		}
		
		return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
	}
	
	static func revert(on connection: MySQLConnection) -> Future<Void> {
		do {
			// Delete all categories from categoryNames
			let futures = try categoryNames.map { name in
				return try Category.query(on: connection).filter(\Category.name == name).delete()
			}
			
			return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
		}
		catch {
			return connection.eventLoop.newFailedFuture(error: error)
		}
	}
}
