import Vapor
import FluentMySQL

final class SearchController: RouteCollection {
	func boot(router: Router) throws {
		// GET /search
		router.getTemplate("search", template: "search", contextGetter: searchPage)
	}
	
	struct SearchRequest: Decodable {
		let city: String?
		let state: USState?
		let category: Category.ID?
	}
	
	struct SearchContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let categories: [Category]?
		let states: [USStateContent]?
		let selectedCity: String?
		let selectedStateID: USState?
		let selectedCategoryID: Category.ID?
		let mentors: [UserProfile]?
	}
	
	func searchPage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) throws -> Future<SearchContext> {
		return Future<SearchRequest>.map(on: req) {
			try req.query.decode(SearchRequest.self)
		}.flatMap(to: SearchContext.self) { content in
			let futureMentors: Future<[UserProfile]>
			if let categoryID = content.category,
			   let city = content.city,
			   let state = content.state
			{
				futureMentors = try Category.find(categoryID, on: req).flatMap(to: [UserProfile].self) { category in
					guard let category = category else {
						throw Alert(.danger, message: "Invalid category ID")
					}
					
					return try category.mentors().query(on: req)
						.filter(\Mentor.stateID == state.rawValue)
						.filter(\Mentor.city == city)
						.all()
						.flatMap(to: [UserProfile].self)
					{ mentors in
						var futureUsers = [Future<UserProfile>]()
						for mentor in mentors {
							try futureUsers.append(mentor.getProfile(on: req))
						}
						return futureUsers.flatten(on: req)
					}
				}
			}
			else {
				futureMentors = .map(on: req) { [] }
			}
			
			return futureMentors.flatMap(to: SearchContext.self) { mentors in
				return try Category.getAll(on: req).map(to: SearchContext.self) { categories in
					let selectedCity = content.city ?? profile?.city
					let selectedStateID = content.state ?? profile?.state?.id
					let selectedCategoryID = content.category
					return SearchContext(
						user: profile,
						alert: alert,
						categories: categories,
						states: USStateContent.all,
						selectedCity: selectedCity,
						selectedStateID: selectedStateID,
						selectedCategoryID: selectedCategoryID,
						mentors: mentors
					)
				}
			}
		}.catchFlatMap { error in
			return try Category.getAll(on: req).map { categories in
				return SearchContext(
					user: profile,
					alert: Alert.fromError(error),
					categories: categories,
					states: USStateContent.all,
					selectedCity: profile?.city,
					selectedStateID: profile?.state?.id,
					selectedCategoryID: nil,
					mentors: []
				)
			}
		}
	}
}
