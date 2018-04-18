import Vapor

final class SearchController: RouteCollection {
	func boot(router: Router) throws {
		router.getTemplate("search", template: "search", contextGetter: search)
	}
	
	struct SearchContext: TemplateContext {
		var user: UserProfile?
		let categories: [Category]
		
		init(user: UserProfile? = nil, categories: [Category]) {
			self.user = user
			self.categories = categories
		}
	}
	
	func search(_ req: Request, profile: UserProfile? = nil) throws -> Future<SearchContext> {
		return try Category.query(on: req).sort(\Category.id, .ascending).all().map { categories in
			return SearchContext(user: profile, categories: categories)
		}
	}
}
