import Vapor

final class CategoryPages: RouteCollection {
	func boot(router: Router) throws {
		let catg = router.grouped("categories")
		
		// GET /categories
		catg.getTemplate(template: "categories", contextGetter: indexContext)
		
		// GET /categories/:id
		catg.getTemplate(Category.parameter, template: "category", contextGetter: categoryContext)
	}
	
	
	struct IndexContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let categories: [Category]
	}
	
	/// Context given to categories.leaf
	func indexContext(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) -> Future<IndexContext> {
		return Category.query(on: req).all().map(to: IndexContext.self) { categories in
			return IndexContext(user: profile, alert: alert, categories: categories)
		}
	}
	
	
	struct CategoryContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let id: Category.ID
		let name: String
		let sampleQuestions: [SampleQuestion]
	}
	
	/// Context given to category.leaf
	func categoryContext(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) throws -> Future<CategoryContext> {
		return try req.parameter(Category.self).flatMap(to: CategoryContext.self) { category in
			return try category.sampleQuestions().query(on: req).all().map(to: CategoryContext.self) { sampleQuestions in
				return try CategoryContext(
					user: profile,
					alert: alert,
					id: category.requireID(),
					name: category.name,
					sampleQuestions: sampleQuestions
				)
			}
		}
	}
}
