import Vapor

final class PagesController: RouteCollection {
	func boot(router: Router) throws {
		// Add homepage view: /
		router.getTemplate(template: "homepage", contextGetter: EmptyTemplateContext.contextGetter)
		
		// Authentication: /login, /register, /logout
		let authController = AuthController()
		try router.register(collection: authController)
		
		// Searching for a mentor: /search
		let searchController = SearchController()
		try router.register(collection: searchController)
		
		// Becoming a mentor: /becomeMentor
		let becomeMentorController = BecomeMentorController()
		try router.register(collection: becomeMentorController)
		
		// Profile page: /profile
		let profileController = ProfileController()
		try router.register(collection: profileController)
	}
}
