import Vapor

final class BecomeMentorController: RouteCollection {
	func boot(router: Router) throws {
		router.getTemplate("becomeMentor", template: "becomeMentor", contextGetter: becomeMentorPage)
	}
	
	struct BecomeMentorContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let categories: [Category]
	}
	
	func becomeMentorPage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) throws -> Future<BecomeMentorContext> {
		return try Category.getAll(on: req).map { categories in
			return BecomeMentorContext(user: profile, alert: alert, categories: categories)
		}
	}
}
