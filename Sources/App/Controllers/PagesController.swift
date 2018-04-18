import Vapor

final class PagesController: RouteCollection {
	func boot(router: Router) throws {
		// Routes under /categories
		let categoryPages = CategoryPages()
		try router.register(collection: categoryPages)
		
		// Authentication
		let authController = AuthController()
		try router.register(collection: authController)
		
		// Add an index route for listing all available pages
		router.getTemplate("pages", template: "index", contextGetter: pages)
		
		// Add homepage view
		router.getTemplate(template: "homepage", contextGetter: EmptyTemplateContext.contextGetter)
	}
	
	struct IndexContext: TemplateContext {
		var user: UserProfile?
		let pages: [String]
		
		init(user: UserProfile? = nil, pages: [String]) {
			self.user = user
			self.pages = pages
		}
	}
	
	/// Render a list of available pages using index.leaf
	func pages(_ req: Request, profile: UserProfile? = nil) throws -> Future<IndexContext> {
		return Future<IndexContext>.map(on: req) {
			return IndexContext(
				user: profile,
				pages: [
					"/",
					"/categories",
					"/login",
					"/register"
				]
			)
		}
	}
}
