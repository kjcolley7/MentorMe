import Vapor

extension Request {
	var user: UserAccount? {
		if let userOpt = try? authenticated(UserAccount.self) {
			return userOpt
		}
		return nil
	}
	
	var profile: UserProfile? {
		if let user = user {
			return try? user.getProfile()
		}
		return nil
	}
}
