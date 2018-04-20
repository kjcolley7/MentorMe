import Vapor
import Authentication

final class BecomeMentorController: RouteCollection {
	func boot(router: Router) throws {
		let authg = router.grouped(RedirectMiddleware<UserAccount>.login(path: "/login"))
		
		// GET /becomeMentor
		authg.getTemplate("becomeMentor", template: "becomeMentor", contextGetter: becomeMentorPage)
		
		// POST /becomeMentor
		authg.post("becomeMentor", use: becomeMentor)
	}
	
	struct BecomeMentorContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let categories: [Category]?
	}
	
	func becomeMentorPage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) throws -> Future<BecomeMentorContext> {
		return try Category.getAll(on: req).map { categories in
			return BecomeMentorContext(user: profile, alert: alert, categories: categories)
		}
	}
	
	struct BecomeMentorRequest: Decodable {
		let cats: [Category.ID]
	}
	
	func becomeMentor(_ req: Request) throws -> Future<Response> {
		let user = try req.requireAuthenticated(UserAccount.self)
		
		return try req.content.decode(BecomeMentorRequest.self).flatMap(to: Response.self) { content in
			var futures = [Future<Void>]()
			for cat in content.cats {
				let mentorRole = try Mentor(
					userID: user.requireID(),
					categoryID: cat,
					city: user.city,
					stateID: user.stateID
				)
				
				// We'll have to wait until all mentors are created before responding
				futures.append(mentorRole.create(on: req).transform(to: ()))
			}
			
			return futures.flatten(on: req).map { _ in
				return req.redirect(to: "/profile")
			}.catchMap { error in
				return req.redirect(to: "/profile")
			}
		}
	}
}
