import Vapor
import Authentication
import Crypto

final class MentorProfileController: RouteCollection {
	func boot(router: Router) throws {
		let authg = router.grouped(RedirectMiddleware<UserAccount>.login(path: "/login"))
		
		// GET /mentor/:id
		authg.getTemplate("mentor", Mentor.parameter, template: "mentorProfile", contextGetter: mentorPage)
	}
	
	struct MentorProfileContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let mentor: UserProfile
	}
	
	func mentorPage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) throws -> Future<MentorProfileContext> {
		return try req.parameter(Mentor.self).flatMap(to: MentorProfileContext.self) { mentor in
			if mentor.id == profile?.id {
				throw Redirect(to: "/profile")
			}
			
			return try mentor.getProfile(on: req).map(to: MentorProfileContext.self) { mentorProfile in
				return MentorProfileContext(
					user: profile,
					alert: alert,
					mentor: mentorProfile
				)
			}
		}
	}
}
