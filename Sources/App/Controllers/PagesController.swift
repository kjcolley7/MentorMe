import Vapor

final class PagesController: RouteCollection {
	func boot(router: Router) throws {
		// Routes under /categories
		let categoryPages = CategoryPages()
		try router.register(collection: categoryPages)
		
		// Add an index route for listing all available pages
		router.get(use: index)
	}
	
	struct IndexContext: Encodable {
		let pages: [String]
	}
	
	/// Render a list of available pages using index.leaf
	func index(_ req: Request) throws -> Future<View> {
		let context = IndexContext(pages: [
			"/categories"
		])
		return try req.view().render("index", context)
	}
}
