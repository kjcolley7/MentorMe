import FluentMySQL
import Vapor

final class Message: MySQLModel {
	var id: Int?
	var mentorshipID: Mentorship.ID
	var body: String
	var fromMentor: Bool
	var sentAt: Date
	
	init(id: Int? = nil, mentorshipID: Mentorship.ID, body: String, fromMentor: Bool, sentAt: Date? = nil) {
		self.id = id
		self.mentorshipID = mentorshipID
		self.body = body
		self.fromMentor = fromMentor
		self.sentAt = sentAt ?? Date()
	}
}

extension Message: Migration {
	static func prepare(on connection: MySQLConnection) -> Future<Void> {
		return Database.create(self, on: connection) { builder in
			try addProperties(to: builder)
			
			// Add FOREIGN KEY reference for mentorshipID
			try builder.addReference(from: \.mentorshipID, to: \Mentorship.id, actions: .update)
		}
	}
}

extension Message: Content { }

extension Message: Parameter { }
