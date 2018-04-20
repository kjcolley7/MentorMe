import Vapor
import Authentication
import Crypto

final class ProfileController: RouteCollection {
	func boot(router: Router) throws {
		let authg = router.grouped(RedirectMiddleware<UserAccount>.login(path: "/login"))
		
		// GET /profile
		authg.getTemplate("profile", template: "profile", contextGetter: EmptyTemplateContext.contextGetter)
		
		// GET /editProfile
		authg.getTemplate("editProfile", template: "editProfile", contextGetter: editProfilePage)
		
		// POST /editProfile
		authg.post("editProfile", use: editProfile)
	}
	
	struct EditProfileContext: TemplateContext {
		let user: UserProfile?
		let alert: Alert?
		let states: [USStateContent]
	}
	
	func editProfilePage(_ req: Request, profile: UserProfile? = nil, alert: Alert? = nil) -> Future<EditProfileContext> {
		return .map(on: req) {
			return EditProfileContext(
				user: profile,
				alert: alert,
				states: USStateContent.all
			)
		}
	}
	
	struct EditProfileRequest: Decodable {
		let name: String?
		let bio: String?
		let email: String?
		let city: String?
		let state: USState?
		let password: String?
		let confirmPassword: String?
	}
	
	func editProfile(_ req: Request) throws -> Future<View> {
		return try req.content.decode(EditProfileRequest.self).flatMap(to: View.self) { content in
			let user = try req.requireAuthenticated(UserAccount.self)
			
			var changed: Bool = false
			
			if let name = content.name,
				!name.isEmpty && user.name != name
			{
				user.name = name
				changed = true
			}
			
			if let bio = content.bio,
				!bio.isEmpty && user.bio != bio
			{
				user.bio = bio
				changed = true
			}
			
			if let email = content.email,
				!email.isEmpty && user.email != email
			{
				user.email = email
				changed = true
			}
			
			if let city = content.city,
				!city.isEmpty && user.city != city
			{
				user.city = city
				changed = true
			}
			
			if let state = content.state,
				user.stateID != state.rawValue
			{
				user.stateID = state.rawValue
				changed = true
			}
			
			if let password = content.password {
				guard let confirmPassword = content.confirmPassword,
				      password == confirmPassword
				else {
					throw Alert(.danger, message: "Passwords don't match!")
				}
				
				if !password.isEmpty {
					user.passwordHash = try BCrypt.hash(password).convert()
					changed = true
				}
			}
			
			let future: Future<Void>
			if changed {
				future = user.save(on: req).then { _ in
					return .done(on: req)
				}
			}
			else {
				future = .done(on: req)
			}
			
			return future.flatMap(to: View.self) {
				return try req.view().render("editProfile", EditProfileContext(
					user: try? user.getProfile(),
					alert: Alert(.success, message: "Profile updated sucessfully!"),
					states: USStateContent.all
				))
			}
		}
	}
}
