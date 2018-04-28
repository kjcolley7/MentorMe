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
				return try user.getMentorships(on: req, asMentor: false, asMentee: true)
					.count()
					.flatMap(to: Response.self)
				{ menteeshipCount in
					if menteeshipCount >= 5 {
						throw Alert(.danger, message: "Cannot be a mentee in more than 5 mentorships at once!")
					}
					
					let mentorship = try Mentorship(
						mentorID: content.mentor,
						menteeID: user.requireID(),
						categoryID: content.category
					)
					
					return mentorship.create(on: req).map(to: Response.self) { created in
						return try req.redirect(to: "/mentorship/\(created.requireID())")
					}
				}.catchFlatMap { error in
					return try UserAccount.find(content.mentor, on: req).flatMap(to: Response.self) { mentor in
						return try req.view().render(
							"/mentor/\(content.mentor)",
							MentorProfileController.MentorProfileContext(
								user: user.getProfile(),
								alert: Alert.fromError(error),
								mentor: mentor?.getProfile(),
								selectedCategoryID: content.category
							)
						).encode(for: req)
					}
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
			return try self.getMessages(on: req, as: req.requireAuthenticated(UserAccount.self), alert: alert)
		}
	}
	
	func mentorshipPage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) -> Future<MentorshipContext> {
		return .flatMap(on: req) {
			return try req.parameter(Mentorship.self).flatMap(to: MentorshipContext.self) { mentorship in
				let user = try req.requireAuthenticated(UserAccount.self)
				let userID = try user.requireID()
				guard mentorship.mentorID == userID || mentorship.menteeID == userID else {
					throw Abort(.notFound, reason: "Could not find requested mentorship!")
				}
				
				return self.getMessages(on: req, as: user, from: mentorship)
			}
		}
	}
	
	func getMessages(
		on conn: DatabaseConnectable,
		as user: UserAccount,
		from mentorship: Mentorship? = nil,
		alert: Alert? = nil
	) -> Future<MentorshipContext> {
		return .flatMap(on: conn) {
			return try user.getMentorships(on: conn).all().flatMap(to: MentorshipContext.self) { mentorships in
				let futureQuestions: Future<[SampleQuestion]>
				if let category = mentorships.first?.categoryID {
					futureQuestions = try SampleQuestion.query(on: conn)
						.filter(\SampleQuestion.categoryID == category)
						.all()
				}
				else {
					futureQuestions = SampleQuestion.query(on: conn).all()
				}
				
				guard let conversation = mentorship ?? mentorships.first else {
					return futureQuestions.map { sampleQuestions in
						return MentorshipContext(
							user: try? user.getProfile(),
							alert: alert,
							mentorships: [],
							mentorship: nil,
							messages: [],
							sampleQuestions: sampleQuestions
						)
					}
				}
				
				return futureQuestions.flatMap(to: MentorshipContext.self) { sampleQuestions in
					return try conversation.messages.query(on: conn)
						.sort(\Message.sentAt, .ascending)
						.all()
						.map(to: MentorshipContext.self)
					{ messages in
						return try MentorshipContext(
							user: try? user.getProfile(),
							alert: alert,
							mentorships: mentorships,
							mentorship: conversation,
							messages: messages.map { message in
								let userIsMentor = try user.requireID() == conversation.mentorID
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
