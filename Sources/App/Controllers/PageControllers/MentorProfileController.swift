import Vapor
import Authentication
import Crypto

final class MentorProfileController: RouteCollection {
	func boot(router: Router) throws {
		let authg = router.grouped(RedirectMiddleware<UserAccount>.login(path: "/login"))
		
		// GET /mentor/:id
		authg.getTemplate("mentor", UserAccount.parameter, template: "mentorProfile", contextGetter: mentorPage)
	}
	
	struct MentorProfileContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let mentor: UserProfile?
		let selectedCategoryID: Int?
	}
	
	struct MentorProfileRequest: Decodable {
		let category: Int?
	}
	
	func mentorPage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) -> Future<MentorProfileContext> {
		return .flatMap(on: req) {
			return try req.parameter(UserAccount.self).map(to: MentorProfileContext.self) { mentor in
				if mentor.id == profile?.id {
					throw Redirect(to: "/profile")
				}
				
				let content = try req.query.decode(MentorProfileRequest.self)
				
				return try MentorProfileContext(
					user: profile,
					alert: alert,
					mentor: mentor.getProfile(),
					selectedCategoryID: content.category
				)
			}
		}
	}
}
