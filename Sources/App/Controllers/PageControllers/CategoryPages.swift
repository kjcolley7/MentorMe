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
		var user: UserProfile?
		let categories: [Category]
		
		init(user: UserProfile? = nil, categories: [Category]) {
			self.user = user
			self.categories = categories
		}
	}
	
	/// Context given to categories.leaf
	func indexContext(_ req: Request, profile: UserProfile? = nil) -> Future<IndexContext> {
		return Category.query(on: req).all().map(to: IndexContext.self) { categories in
			return IndexContext(user: profile, categories: categories)
		}
	}
	
	
	struct CategoryContext: TemplateContext {
		var user: UserProfile?
		let id: Category.ID
		let name: String
		let sampleQuestions: [SampleQuestion]
		
		init(user: UserProfile? = nil, id: Category.ID, name: String, sampleQuestions: [SampleQuestion]) {
			self.user = user
			self.id = id
			self.name = name
			self.sampleQuestions = sampleQuestions
		}
	}
	
	/// Context given to category.leaf
	func categoryContext(_ req: Request, profile: UserProfile? = nil) throws -> Future<CategoryContext> {
		return try req.parameter(Category.self).flatMap(to: CategoryContext.self) { category in
			return try category.sampleQuestions().query(on: req).all().map(to: CategoryContext.self) { sampleQuestions in
				return try CategoryContext(
					user: profile,
					id: category.requireID(),
					name: category.name,
					sampleQuestions: sampleQuestions
				)
			}
		}
	}
}
