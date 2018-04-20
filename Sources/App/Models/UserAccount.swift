import FluentMySQL
import Vapor
import Authentication
import Crypto


final class UserAccount: MySQLModel {
	var id: Int?
	var email: String
	var passwordHash: String
	var name: String
	var bio: String
	var city: String
	var stateID: Int
	var joinedAt: Date
	
	init(
		id: Int? = nil,
		email: String,
		passwordHash: String,
		name: String,
		bio: String,
		city: String,
		stateID: Int,
		joinedAt: Date? = nil
	) {
		self.id = id
		self.email = email
		self.passwordHash = passwordHash
		self.name = name
		self.bio = bio
		self.city = city
		self.stateID = stateID
		self.joinedAt = joinedAt ?? Date()
	}
	
	convenience init(
		email: String,
		password: String,
		passwordRepeat: String? = nil,
		name: String,
		bio: String,
		city: String,
		state: USState
	) throws {
		if let passwordRepeat = passwordRepeat,
		   password != passwordRepeat
		{
			throw Abort(.badRequest, reason: "Passwords do not match")
		}
		
		try self.init(
			email: email,
			passwordHash: BCrypt.hash(password).convert(),
			name: name,
			bio: bio,
			city: city,
			stateID: state.rawValue
		)
	}
}

extension UserAccount: Migration {
	static func prepare(on connection: MySQLConnection) -> Future<Void> {
		return Database.create(self, on: connection) { builder in
			try addProperties(to: builder)
			
			// Email is UNIQUE
			try builder.addIndex(to: \.email, isUnique: true)
		}
	}
}

extension UserAccount: Parameter { }

extension UserAccount: PasswordAuthenticatable {
	static var usernameKey: WritableKeyPath<UserAccount, String> {
		return \UserAccount.email
	}
	
	static var passwordKey: WritableKeyPath<UserAccount, String> {
		return \UserAccount.passwordHash
	}
}

extension UserAccount {
	static func register(
		email: String,
		password: String,
		passwordRepeat: String? = nil,
		name: String,
		bio: String,
		city: String,
		state: USState,
		on connection: DatabaseConnectable
	) -> Future<UserAccount> {
		do {
			return try UserAccount(
				email: email,
				password: password,
				passwordRepeat: passwordRepeat,
				name: name,
				bio: bio,
				city: city,
				state: state
			).create(on: connection).catchMap { error in
				throw Abort(.badRequest, reason: "An account with that email already exists. (\(error))")
			}
		}
		catch {
			return connection.eventLoop.newFailedFuture(error: error)
		}
	}
}

extension UserAccount: SessionAuthenticatable { }


/// Data fields accessible to API routes and Leaf templates
struct UserProfile: Content {
	let id: Int
	let email: String
	let name: String
	let bio: String
	let city: String
	let state: USStateContent?
	let joinedAt: String
}

extension UserAccount {
	/// Return the user's profile information
	func getProfile() throws -> UserProfile {
		return try UserProfile(
			id: requireID(),
			email: email,
			name: name,
			bio: bio,
			city: city,
			state: USState(rawValue: stateID)?.content,
			// XXX: Trying to JSON-encode dates currently results in a server crash
			joinedAt: "\(joinedAt.timeIntervalSince1970)"
		)
	}
}
