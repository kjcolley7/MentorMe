import Vapor
import Authentication

final class MentorshipController: RouteCollection {
	func boot(router: Router) throws {
		let authg = router.grouped(RedirectMiddleware<UserAccount>.login(path: "/login"))
		
		// POST /mentorship
		authg.post("mentorship", use: newMentorship)
	}
	
	func newMentorship(_ req: Request) throws -> Future<Response> {
		// TODO
		throw Abort(.notImplemented)
	}
}
