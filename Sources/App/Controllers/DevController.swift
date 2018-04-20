import Vapor

class DevController: RouteCollection {
	func boot(router: Router) throws {
		let devg = router.grouped("dev")
		
		// GET /dev/: Lists all available pages
		devg.getTemplate(template: "index", contextGetter: index)
		
		// Routes under /dev/categories
		let categoryPages = CategoryPages()
		try devg.register(collection: categoryPages)
	}
	
	struct IndexContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let pages: [String]
	}
	
	/// Render a list of available pages using index.leaf
	func index(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) throws -> Future<IndexContext> {
		return Future<IndexContext>.map(on: req) {
			return IndexContext(
				user: profile,
				alert: alert,
				pages: [
					"/",
					"/login",
					"/register",
					"/search",
					"/becomeMentor",
					"/dev/categories"
				]
			)
		}
	}
}
