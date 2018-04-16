import Vapor

final class APIController: RouteCollection {
	func boot(router: Router) throws {
		// API is mounted under /api/v1
		let apig = router.grouped("api", "v1")
		
		// Routes under /api/v1/categories
		let categoryController = CategoryController()
		try apig.register(collection: categoryController)
		
		// Routes under /api/v1/sampleQuestions
		let sampleQuestionController = SampleQuestionController()
		try apig.register(collection: sampleQuestionController)
	}
}
