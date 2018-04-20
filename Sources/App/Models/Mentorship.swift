import FluentMySQL
import Vapor

final class Mentorship: MySQLModel {
	enum Status: Int, Content {
		case proposed, accepted, finished
	}
	
	var id: Int?
	var mentorID: Mentor.ID
	var menteeID: UserAccount.ID
	var status: Status
	var startedAt: Date
	var acceptedAt: Date?
	var endedAt: Date?
	var mentorRating: Int?
	var menteeRating: Int?
	
	init(
		id: Int? = nil,
		mentorID: Mentor.ID,
		menteeID: UserAccount.ID,
		status: Status = .proposed,
		startedAt: Date? = nil,
		acceptedAt: Date? = nil,
		endedAt: Date? = nil,
		mentorRating: Int? = nil,
		menteeRating: Int? = nil
	) {
		self.id = id
		self.mentorID = mentorID
		self.menteeID = menteeID
		self.status = status
		self.startedAt = startedAt ?? Date()
		self.acceptedAt = acceptedAt ?? Date()
		self.endedAt = endedAt ?? Date()
		self.mentorRating = mentorRating
		self.menteeRating = menteeRating
	}
}

extension Mentorship: Migration {
	static func prepare(on connection: MySQLConnection) -> Future<Void> {
		return Database.create(self, on: connection) { builder in
			try addProperties(to: builder)
			
			// Add FOREIGN KEY reference for mentorID
			try builder.addReference(from: \.mentorID, to: \Mentor.id, actions: .update)
			
			// Add FOREIGN KEY reference for menteeID
			try builder.addReference(from: \.menteeID, to: \UserAccount.id, actions: .update)
		}
	}
}

extension Mentorship: Content { }

extension Mentorship: Parameter { }

extension Mentorship {
	func getMessages(on conn: DatabaseConnectable) -> Children<Mentorship, Message> {
		return children(\Message.mentorshipID)
	}
}
