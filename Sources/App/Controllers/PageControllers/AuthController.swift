import Vapor
import Authentication
import Crypto

final class AuthController: RouteCollection {
	func boot(router: Router) throws {
		// GET /register
		router.getTemplate("register", template: "register", contextGetter: EmptyTemplateContext.contextGetter)
		
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
	
	
	struct RegisterRequest: Decodable {
		let email: String
		let password: String
		let passwordRepeat: String
		let firstName: String
		let city: String
	}
	
	/// Register a new user account and then redirect to the main page
	func register(_ req: Request) throws -> Future<Response> {
		return try req.content.decode(RegisterRequest.self).flatMap(to: Response.self) { content in
			return UserAccount.register(
				email: content.email,
				password: content.password,
				passwordRepeat: content.passwordRepeat,
				name: content.firstName,
				city: content.city,
				on: req
			).map(to: Response.self) { account in
				// On successful registration, redirect to the home page
				try req.authenticateSession(account)
				return req.redirect(to: "/")
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
					// TODO: Instead render login template with an error message added
					throw Abort(.badRequest, reason: "Invalid email or password!")
				}
				
				// On successful login redirect to the home page
				try req.authenticateSession(user)
				return req.redirect(to: "/")
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
		let email: String
		if let user = try req.authenticated(UserAccount.self) {
			email = user.email
		}
		else {
			email = "<UNKNOWN>"
		}
		
		return "Authenticated! email=\(email)"
	}
}
