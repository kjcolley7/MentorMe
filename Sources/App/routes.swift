import Routing
import Vapor
import FluentMySQL
import Leaf

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
	// Create /api/v1 routes
	let apiController = APIController()
	try router.register(collection: apiController)
	
	// Create view routes
	let pagesController = PagesController()
	try router.register(collection: pagesController)
	
	// Create /dev routes
	let devController = DevController()
	try router.register(collection: devController)
}
