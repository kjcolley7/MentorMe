import Routing
import Vapor
import Leaf


protocol TemplateContext: Content {
	var user: UserProfile? { get }
	var alert: Alert? { get }
}

struct EmptyTemplateContext: TemplateContext {
	let user: UserProfile?
	let alert: Alert?
	
	static func contextGetter(
		_ req: Request,
		_ profile: UserProfile? = nil,
		_ alert: Alert? = nil
	) throws -> Future<EmptyTemplateContext> {
		return .map(on: req) {
			return EmptyTemplateContext(user: profile, alert: alert)
		}
	}
}


extension Router {
	func getTemplate<T>(
		_ path: DynamicPathComponentRepresentable...,
		template: String,
		contextGetter: @escaping (_ req: Request, _ profile: UserProfile?, _ alert: Alert?) throws -> Future<T>
	) where T: TemplateContext {
		// GET /foo -> View
		let pathComponents = path.makeDynamicPathComponents()
		on(.GET, at: pathComponents) { req -> Future<View> in
			return try contextGetter(req, req.profile, nil).flatMap(to: View.self) { context -> Future<View> in
				return try (req.view() as TemplateRenderer).render(template, context)
			}.catchFlatMap { error in
				let context = EmptyTemplateContext(
					user: req.profile,
					alert: Alert.fromError(error)
				)
				return try (req.view() as TemplateRenderer).render(template, context)
			}
		}
		
		// FIXME: What's the proper way to access env.isRelease here?
//		if Environment.get("prod") == nil {
			// GET /foo/json -> JSON
			let jsonComponents = DynamicPathComponent.constant(PathComponent(string: "json")).makeDynamicPathComponents()
			on(.GET, at: pathComponents + jsonComponents) { req -> Future<T> in
				do {
					return try contextGetter(req, req.profile, nil)
				} catch {
					return req.eventLoop.newFailedFuture(error: error)
				}
			}
//		}
	}
}
