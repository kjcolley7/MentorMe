import Vapor

/// Controls basic CRUD operations on `Category`s.
final class CategoryController {
	/// Returns a list of all `Category`s.
	func index(_ req: Request) throws -> Future<[Category]> {
		return Category.query(on: req).all()
	}
	
	/// Returns an individual `Category`.
	func get(_ req: Request) throws -> Future<Category> {
		return try req.parameter(Category.self)
	}
}
