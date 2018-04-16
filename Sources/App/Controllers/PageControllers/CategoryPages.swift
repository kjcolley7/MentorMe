import Vapor

final class CategoryPages: RouteCollection {
	func boot(router: Router) throws {
		let catg = router.grouped("categories")
		
		// GET /categories
		catg.get(use: index)
		
		// GET /categories/:id
		catg.get(Category.parameter, use: get)
	}
	
	
	struct IndexContext: Encodable {
		let categories: [Category]
	}
	
	/// Render a list of categories using categories.leaf
	func index(_ req: Request) -> Future<View> {
		return Category.query(on: req).all().flatMap(to: View.self) { categories in
			let context = IndexContext(categories: categories)
			return try req.view().render("categories", context)
		}
	}
	
	
	struct GetContext: Encodable {
		let id: Category.ID
		let name: String
		let sampleQuestions: [SampleQuestion]
	}
	
	/// Render sample questions within a specific category using category.leaf
	func get(_ req: Request) throws -> Future<View> {
		return try req.parameter(Category.self).flatMap(to: View.self) { category in
			return try category.sampleQuestions().query(on: req).all().flatMap(to: View.self) { sampleQuestions in
				let context = GetContext(
					id: category.id!,
					name: category.name,
					sampleQuestions: sampleQuestions
				)
				return try req.view().render("category", context)
			}
		}
	}
}
