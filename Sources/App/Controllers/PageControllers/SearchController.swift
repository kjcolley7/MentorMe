import Vapor

final class SearchController: RouteCollection {
	func boot(router: Router) throws {
		router.getTemplate("search", template: "search", contextGetter: searchPage)
	}
	
	struct SearchContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let categories: [Category]
	}
	
	func searchPage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) throws -> Future<SearchContext> {
		return try Category.getAll(on: req).map { categories in
			return SearchContext(user: profile, alert: alert, categories: categories)
		}
	}
}
