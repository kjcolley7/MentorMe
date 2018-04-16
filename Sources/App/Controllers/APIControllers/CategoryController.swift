import Vapor

/// Controls basic CRUD operations on `Category`s.
final class CategoryController: RouteCollection {
	func boot(router: Router) throws {
		let categoryg = router.grouped("categories")
		
		// GET /categories
		categoryg.get(use: index)
		
		// GET /categories/:categoryID
		categoryg.get(Category.parameter, use: get)
		
		// GET /categories/:categoryID/sampleQuestions
		categoryg.get(Category.parameter, "sampleQuestions", use: listSampleQuestions)
	}
	
	/// Returns a list of all `Category`s.
	func index(_ req: Request) throws -> Future<[Category]> {
		return Category.query(on: req).all()
	}
	
	/// Returns an individual `Category`.
	func get(_ req: Request) throws -> Future<Category> {
		return try req.parameter(Category.self)
	}
	
	/// Returns all `SampleQuestion`s associated with this `Category`.
	func listSampleQuestions(_ req: Request) throws -> Future<[SampleQuestion]> {
		return try req.parameter(Category.self).flatMap(to: [SampleQuestion].self) { category in
			return try category.sampleQuestions().query(on: req).all()
		}
	}
}
