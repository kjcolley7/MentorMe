import Vapor
import Authentication
import FluentMySQL

final class MentorshipController: RouteCollection {
	func boot(router: Router) throws {
		let chatg = router.grouped(RedirectMiddleware<UserAccount>.login(path: "/login")).grouped("mentorship")
		
		// GET /mentorship
		chatg.getTemplate(template: "messaging", contextGetter: mentorshipIndex)
		
		// POST /mentorship
		chatg.post(use: newMentorship)
		
		// GET /mentorship/:id
		chatg.getTemplate(Mentorship.parameter, template: "messaging", contextGetter: mentorshipPage)
		
		// POST /mentorship/:id/sendMessage
		chatg.post(Mentorship.parameter, "sendMessage", use: sendMessage)
	}
	
	struct MentorshipRequest: Decodable {
		let mentor: Int
		let category: Int?
	}
	
	func newMentorship(_ req: Request) -> Future<Response> {
		return .flatMap(on: req) {
			return try req.content.decode(MentorshipRequest.self).flatMap(to: Response.self) { content in
				let user = try req.requireAuthenticated(UserAccount.self)
				let mentorship = try Mentorship(
					mentorID: content.mentor,
					menteeID: user.requireID(),
					categoryID: content.category
				)
				
				return mentorship.create(on: req).map(to: Response.self) { created in
					return try req.redirect(to: "/mentorship/\(created.requireID())")
				}
			}
		}
	}
	
	struct MessageContent: Content {
		let id: Int
		let body: String
		let sentAt: Date
		let fromYou: Bool
	}
	
	struct MentorshipContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let mentorships: [Mentorship]?
		let mentorship: Mentorship?
		let messages: [MessageContent]?
		let sampleQuestions: [SampleQuestion]?
	}
	
	func mentorshipIndex(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) -> Future<MentorshipContext> {
		return .flatMap(on: req) {
			let user = try req.requireAuthenticated(UserAccount.self)
			return try user.getMentorships(on: req).all().flatMap(to: MentorshipContext.self) { mentorships in
				let futureMessages: Future<[Message]>
				if let mentorship = mentorships.first {
					futureMessages = try mentorship.messages.query(on: req).sort(\Message.sentAt, .ascending).all()
				}
				else {
					futureMessages = .map(on: req) { [] }
				}
				
				return futureMessages.flatMap(to: MentorshipContext.self) { messages in
					let futureQuestions: Future<[SampleQuestion]>
					if let category = mentorships.first?.categoryID {
						futureQuestions = try SampleQuestion.query(on: req)
							.filter(\SampleQuestion.categoryID == category)
							.all()
					}
					else {
						futureQuestions = SampleQuestion.query(on: req).all()
					}
					
					return futureQuestions.map(to: MentorshipContext.self) { sampleQuestions in
						return try MentorshipContext(
							user: profile,
							alert: alert,
							mentorships: mentorships,
							mentorship: mentorships.first,
							messages: messages.map { message in
								let userIsMentor = try user.requireID() == mentorships.first?.id
								return try MessageContent(
									id: message.requireID(),
									body: message.body,
									sentAt: message.sentAt,
									fromYou: message.fromMentor == userIsMentor
								)
							},
							sampleQuestions: sampleQuestions
						)
					}
				}
			}
		}
	}
	
	func mentorshipPage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) -> Future<MentorshipContext> {
		return .flatMap(on: req) {
			return try req.parameter(Mentorship.self).flatMap(to: MentorshipContext.self) { mentorship in
				let user = try req.requireAuthenticated(UserAccount.self)
				guard let userID = user.id else {
					throw Abort(.unauthorized, reason: "User is not authenticated")
				}
				
				guard mentorship.mentorID == userID || mentorship.menteeID == userID else {
					throw Abort(.notFound, reason: "Could not find requested mentorship!")
				}
				
				return try user.getMentorships(on: req).all().flatMap(to: MentorshipContext.self) { mentorships in
					return try mentorship.messages.query(on: req)
						.sort(\Message.sentAt, .ascending)
						.all()
						.flatMap(to: MentorshipContext.self)
					{ messages in
						let futureQuestions: Future<[SampleQuestion]>
						if let category = mentorships.first?.categoryID {
							futureQuestions = try SampleQuestion.query(on: req)
								.filter(\SampleQuestion.categoryID == category)
								.all()
						}
						else {
							futureQuestions = SampleQuestion.query(on: req).all()
						}
						
						return futureQuestions.map(to: MentorshipContext.self) { sampleQuestions in
							return try MentorshipContext(
								user: profile,
								alert: alert,
								mentorships: mentorships,
								mentorship: mentorship,
								messages: messages.map { message in
									let userIsMentor = try user.requireID() == mentorships.first?.id
									return try MessageContent(
										id: message.requireID(),
										body: message.body,
										sentAt: message.sentAt,
										fromYou: message.fromMentor == userIsMentor
									)
								},
								sampleQuestions: sampleQuestions
							)
						}
					}
				}
			}
		}
	}
	
	struct MessageRequest: Decodable {
		let body: String
	}
	
	func sendMessage(_ req: Request) -> Future<Response> {
		return .flatMap(on: req) {
			let user = try req.requireAuthenticated(UserAccount.self)
			return try req.parameter(Mentorship.self).flatMap(to: Response.self) { mentorship in
				return try req.content.decode(MessageRequest.self).flatMap(to: Response.self) { content in
					return mentorship.sendMessage(on: req, as: user, body: content.body).map(to: Response.self) { message in
						return try req.redirect(to: "/mentorship/\(mentorship.requireID())")
					}
				}
			}
		}
	}
}
