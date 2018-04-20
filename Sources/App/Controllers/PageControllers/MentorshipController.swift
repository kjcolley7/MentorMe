import Vapor
import Authentication
import FluentMySQL

final class MentorshipController: RouteCollection {
	func boot(router: Router) throws {
		let authg = router.grouped(RedirectMiddleware<UserAccount>.login(path: "/login"))
		
		// GET /mentorship
		authg.getTemplate("mentorship", template: "messaging", contextGetter: mentorshipIndex)
		
		// POST /mentorship
		authg.post("mentorship", use: newMentorship)
		
		// GET /mentorship/:id
		authg.getTemplate("mentorship", Mentorship.parameter, template: "messaging", contextGetter: mentorshipPage)
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
	
	struct MentorshipContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let mentorships: [Mentorship]?
		let mentorship: Mentorship?
		let messages: [Message]?
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
					
					return futureQuestions.map { sampleQuestions in
						return MentorshipContext(
							user: profile,
							alert: alert,
							mentorships: mentorships,
							mentorship: mentorships.first,
							messages: messages,
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
						
						return futureQuestions.map { sampleQuestions in
							return MentorshipContext(
								user: profile,
								alert: alert,
								mentorships: mentorships,
								mentorship: mentorship,
								messages: messages,
								sampleQuestions: sampleQuestions
							)
						}
					}
				}
			}
		}
	}
}
