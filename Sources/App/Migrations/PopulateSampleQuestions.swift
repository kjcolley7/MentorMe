import FluentMySQL

final class PopulateSampleQuestions: Migration {
	typealias Database = MySQLDatabase
	
	static let sampleQuestions = [
		"Food and Drink": [
			"What are some good vegan options?",
			"What restaurants have the best burgers?",
			"Is there any good Indian food in the area?"
		],
		"Nature": [
			"Where are the best places for birdwatching?"
		],
		"Art": [
			"What's a good place to find modern sculptures?"
		],
		"Sports": [
			"Are there any indoor soccer arenas nearby?",
		],
		"Music": [
			"Where can I buy vinyl records?",
			"What are the best concert venues?"
		],
		"Games": [
			"Are there any pinball bars around?",
			"Where should I go to play arcade games?"
		],
		"Parties": [
			"Which apartment complexes are known for college parties?"
		],
		"Other": [
			"What roads often have police speedtraps?"
		]
	]
	
	static func getCategoryID(on connection: MySQLConnection, categoryName: String) -> Future<Category.ID> {
		do {
			// First look up the category by its name
			return try Category.query(on: connection)
				.filter(\Category.name == categoryName)
				.first()
				.map(to: Category.ID.self) { category in
					guard let category = category else {
						throw FluentError(
							identifier: "addSampleQuestion_noSuchCategory",
							reason: "No category named \(categoryName) exists!",
							source: .capture()
						)
					}
					
					// Once we have found the category, return its id
					return category.id!
				}
		}
		catch {
			return connection.eventLoop.newFailedFuture(error: error)
		}
	}
	
	static func addSampleQuestions(
		on connection: MySQLConnection,
		toCategoryWithName categoryName: String,
		questions: [String]
	) -> Future<Void> {
		// Look up the category's ID
		return getCategoryID(on: connection, categoryName: categoryName)
			.flatMap(to: Void.self) { categoryID in
				// Add each question to the category
				let futures = questions.map { question in
					// INSERT the question
					return SampleQuestion(categoryID: categoryID, question: question)
						.create(on: connection)
						.map(to: Void.self) { _ in return }
				}
				
				return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
			}
	}
	
	static func prepare(on connection: MySQLConnection) -> Future<Void> {
		// Insert all categories from categoryNames
		let futures = sampleQuestions.map { categoryName, questions in
			return addSampleQuestions(on: connection, toCategoryWithName: categoryName, questions: questions)
		}
		
		return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
	}
	
	static func deleteSampleQuestions(
		on connection: MySQLConnection,
		toCategoryWithName categoryName: String,
		questions: [String]
	) -> Future<Void> {
		// Look up the category's ID
		return getCategoryID(on: connection, categoryName: categoryName)
			.flatMap(to: Void.self) { categoryID in
				// Delete each question from the category
				let futures = try questions.map { question in
					// DELETE the question if it exists
					return try SampleQuestion.query(on: connection)
						.filter(\.categoryID == categoryID)
						.filter(\.question == question)
						.delete()
				}
				
				return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
		}
	}
	
	static func revert(on connection: MySQLConnection) -> Future<Void> {
		// Insert all categories from categoryNames
		let futures = sampleQuestions.map { categoryName, questions in
			return deleteSampleQuestions(on: connection, toCategoryWithName: categoryName, questions: questions)
		}
		
		return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
	}
}
