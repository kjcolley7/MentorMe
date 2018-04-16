import FluentMySQL
import Vapor

final class SampleQuestion: MySQLModel {
	var id: Int?
	var categoryID: Category.ID
	var question: String
	
	init(id: Int? = nil, categoryID: Category.ID, question: String) {
		self.id = id
		self.categoryID = categoryID
		self.question = question
	}
}

extension SampleQuestion: Migration {
	static func prepare(on connection: MySQLConnection) -> Future<Void> {
		return Database.create(self, on: connection) { builder in
			try addProperties(to: builder)
			
			// Add FOREIGN KEY reference, with ON UPDATE/DELETE CASCADE actions
			try builder.addReference(from: \.categoryID, to: \Category.id, actions: .update)
			
			// (categoryID, question) pairs are UNIQUE
			try builder.addIndex(to: \.categoryID, \.question, isUnique: true)
		}
	}
}

extension SampleQuestion: Content { }

extension SampleQuestion: Parameter { }
