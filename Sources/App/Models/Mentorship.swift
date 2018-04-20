import FluentMySQL
import Vapor

final class Mentorship: MySQLModel {
	enum Status: Int, Content {
		case proposed, accepted, finished
	}
	
	var id: Int?
	var mentorID: UserAccount.ID
	var menteeID: UserAccount.ID
	var categoryID: Category.ID?
	var status: Int
	var lastActiveAt: Date
	var startedAt: Date
	var acceptedAt: Date?
	var endedAt: Date?
	var mentorRating: Int?
	var menteeRating: Int?
	
	init(
		id: Int? = nil,
		mentorID: UserAccount.ID,
		menteeID: UserAccount.ID,
		categoryID: Category.ID? = nil,
		statusCode: Int,
		lastActiveAt: Date? = nil,
		startedAt: Date? = nil,
		acceptedAt: Date? = nil,
		endedAt: Date? = nil,
		mentorRating: Int? = nil,
		menteeRating: Int? = nil
	) throws {
		guard mentorID != menteeID else {
			throw Abort(.badRequest, reason: "A user cannot be their own mentor.")
		}
		
		let now = Date()
		
		self.id = id
		self.mentorID = mentorID
		self.menteeID = menteeID
		self.categoryID = categoryID
		self.status = statusCode
		self.lastActiveAt = lastActiveAt ?? now
		self.startedAt = startedAt ?? now
		self.acceptedAt = acceptedAt
		self.endedAt = endedAt
		self.mentorRating = mentorRating
		self.menteeRating = menteeRating
	}
	
	convenience init(
		id: Int? = nil,
		mentorID: UserAccount.ID,
		menteeID: UserAccount.ID,
		categoryID: Category.ID? = nil,
		status: Status = .proposed,
		lastActiveAt: Date? = nil,
		startedAt: Date? = nil,
		acceptedAt: Date? = nil,
		endedAt: Date? = nil,
		mentorRating: Int? = nil,
		menteeRating: Int? = nil
	) throws {
		try self.init(
			id: id,
			mentorID: mentorID,
			menteeID: menteeID,
			categoryID: categoryID,
			statusCode: status.rawValue,
			lastActiveAt: lastActiveAt,
			startedAt: startedAt,
			acceptedAt: acceptedAt,
			endedAt: endedAt,
			mentorRating: mentorRating,
			menteeRating: menteeRating
		)
	}
}

extension Mentorship: Migration {
	static func prepare(on connection: MySQLConnection) -> Future<Void> {
		return Database.create(self, on: connection) { builder in
			try addProperties(to: builder)
			
			// Add FOREIGN KEY reference for mentorID
			try builder.addReference(from: \.mentorID, to: \UserAccount.id, actions: .update)
			
			// Add FOREIGN KEY reference for menteeID
			try builder.addReference(from: \.menteeID, to: \UserAccount.id, actions: .update)
			
			// Add FOREIGN KEY reference for categoryID
			try builder.addReference(from: \.categoryID, to: \Category.id, actions: .update)
		}
	}
}

extension Mentorship: Content { }

extension Mentorship: Parameter { }

extension Mentorship {
	var messages: Children<Mentorship, Message> {
		return children(\Message.mentorshipID)
	}
	
	func sendMessage(on conn: DatabaseConnectable, as user: UserAccount, body: String) -> Future<Message> {
		return .flatMap(on: conn) {
			let message = try Message(
				mentorshipID: self.requireID(),
				body: body,
				fromMentor: user.requireID() == self.mentorID
			)
			
			return message.create(on: conn).flatMap(to: Message.self) { message in
				self.lastActiveAt = message.sentAt
				return self.update(on: conn).transform(to: message)
			}
		}
	}
}
