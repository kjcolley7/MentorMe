import FluentMySQL
import Vapor

final class Mentor: MySQLModel {
	var id: Int?
	var userID: UserAccount.ID
	var categoryID: Category.ID
	var city: String
	var stateID: Int
	var declaredAt: Date
	
	init(
		id: Int? = nil,
		userID: UserAccount.ID,
		categoryID: Category.ID,
		city: String,
		stateID: Int,
		declaredAt: Date? = nil
	) {
		self.id = id
		self.userID = userID
		self.categoryID = categoryID
		self.city = city
		self.stateID = stateID
		self.declaredAt = declaredAt ?? Date()
	}
}

extension Mentor: Migration {
	static func prepare(on connection: MySQLConnection) -> Future<Void> {
		return Database.create(self, on: connection) { builder in
			try addProperties(to: builder)
			
			// Add FOREIGN KEY reference to UserAccount
			try builder.addReference(from: \.userID, to: \UserAccount.id, actions: .update)
			
			// Add FOREIGN KEY reference to Category
			try builder.addReference(from: \.categoryID, to: \Category.id, actions: .update)
			
			// (userID, categoryID) pairs are UNIQUE
			try builder.addIndex(to: \.userID, \.categoryID, isUnique: true)
			
			// Allow quick lookups based on category
			try builder.addIndex(to: \.categoryID)
			
			// Allow quick lookups based on city and state
			try builder.addIndex(to: \.city, \.stateID)
		}
	}
}

extension Mentor: Content { }

extension Mentor: Parameter { }

extension Mentor {
	var user: Parent<Mentor, UserAccount> {
		return parent(\.userID)
	}
	
	func getProfile(on conn: DatabaseConnectable) throws -> Future<UserProfile> {
		return try user.get(on: conn).map(to: UserProfile.self) { account in
			return try account.getProfile()
		}
	}
}
