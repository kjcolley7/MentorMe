import Vapor
import Authentication
import Crypto

final class AuthController: RouteCollection {
	func boot(router: Router) throws {
		// GET /register
		router.getTemplate("register", template: "register", contextGetter: registerPage)
		
		// POST /register
		router.post("register", use: register)
		
		// GET /login
		router.getTemplate("login", template: "login", contextGetter: EmptyTemplateContext.contextGetter)
		
		// POST /login
		router.post("login", use: login)
		
		// POST /logout
		router.post("logout", use: logout)
		
		// Routes that can only be accessed when the user is authenticated
		let authg = router.grouped(RedirectMiddleware<UserAccount>.login(path: "/login"))
		
		// GET /testauth
		authg.get("testAuth", use: testAuth)
	}
	
	struct RegisterContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let states: [USStateContent]
	}
	
	func registerPage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) throws -> Future<RegisterContext> {
		return .map(on: req) {
			return RegisterContext(
				user: profile,
				alert: alert,
				states: USStateContent.all
			)
		}
	}
	
	
	struct RegisterRequest: Decodable {
		let email: String
		let password: String
		let passwordRepeat: String
		let name: String
		let bio: String?
		let city: String
		let state: USState
	}
	
	/// Register a new user account and then redirect to the main page
	func register(_ req: Request) throws -> Future<Response> {
		return try req.content.decode(RegisterRequest.self).flatMap(to: Response.self) { content in
			return UserAccount.register(
				email: content.email,
				password: content.password,
				passwordRepeat: content.passwordRepeat,
				name: content.name,
				bio: content.bio ?? "",
				city: content.city,
				state: content.state,
				on: req
			).map(to: Response.self) { account in
				// On successful registration, redirect to the home page
				try req.authenticateSession(account)
				return req.redirect(to: "/")
			}
		}.catchFlatMap { error in
			return try req.view().render("register", RegisterContext(
				user: req.profile,
				alert: Alert.fromError(error),
				states: USStateContent.all
			)).flatMap(to: Response.self) { view in
				return try view.encode(for: req)
			}
		}
	}
	
	
	struct LoginRequest: Decodable {
		let email: String
		let password: String
	}
	
	/// Login and then redirect to the main page
	func login(_ req: Request) throws -> Future<Response> {
		return try req.content.decode(LoginRequest.self).flatMap(to: Response.self) { content in
			return UserAccount.authenticate(
				username: content.email,
				password: content.password,
				using: BCrypt,
				on: req
			).map(to: Response.self) { user in
				guard let user = user else {
					throw Abort(.badRequest, reason: "Invalid email or password!")
				}
				
				// On successful login redirect to the home page
				try req.authenticateSession(user)
				return req.redirect(to: "/")
			}
		}.catchFlatMap { error in
			return try req.view().render("login", EmptyTemplateContext(
				user: req.profile,
				alert: Alert.fromError(error)
			)).flatMap(to: Response.self) { view in
				return try view.encode(for: req)
			}
		}
	}
	
	/// Logout and then redirect to the main page
	func logout(_ req: Request) throws -> Response {
		// On logout redirect to the home page
		try req.unauthenticateSession(UserAccount.self)
		return req.redirect(to: "/")
	}
	
	/// Check if the user is authenticated
	func testAuth(_ req: Request) throws -> String {
		let email = req.user?.email ?? "<UNKNOWN>"
		return "Authenticated! email=\(email)"
	}
}
