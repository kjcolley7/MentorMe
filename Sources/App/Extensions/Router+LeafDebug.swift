import Routing
import Vapor
import Leaf

protocol TemplateContext: Content {
	var user: UserProfile? { get set }
}

struct EmptyTemplateContext: TemplateContext {
	var user: UserProfile?
	
	static func contextGetter(_ req: Request, _ profile: UserProfile? = nil) throws -> Future<EmptyTemplateContext> {
		return .map(on: req) {
			return EmptyTemplateContext(user: profile)
		}
	}
}


extension Router {
	func getTemplate<T>(
		_ path: DynamicPathComponentRepresentable...,
		template: String,
		contextGetter: @escaping (_ req: Request, _ profile: UserProfile?) throws -> Future<T>
	) where T: TemplateContext {
		func contextWithUser(_ req: Request) throws -> Future<T> {
			let profile: UserProfile?
			if let userOpt = try? req.authenticated(UserAccount.self),
				let user = userOpt,
				let userProfile = try? user.getProfile()
			{
				profile = userProfile
			}
			else {
				profile = nil
			}
			
			return try contextGetter(req, profile)
		}
		
		// GET /foo -> View
		let pathComponents = path.makeDynamicPathComponents()
		on(.GET, at: pathComponents) { req -> Future<View> in
			return try contextWithUser(req).flatMap(to: View.self) { context -> Future<View> in
				return try (req.view() as TemplateRenderer).render(template, context)
			}
		}
		
		// FIXME: What's the proper way to access env.isRelease here?
//		if Environment.get("prod") == nil {
			// GET /foo/json -> JSON
			let jsonComponents = DynamicPathComponent.constant(PathComponent(string: "json")).makeDynamicPathComponents()
			on(.GET, at: pathComponents + jsonComponents) { req -> Future<T> in
				do {
					return try contextWithUser(req)
				} catch {
					return req.eventLoop.newFailedFuture(error: error)
				}
			}
//		}
	}
}
