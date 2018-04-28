import Vapor
import FluentMySQL
import Leaf
import Authentication
import Redis
import Crypto

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
	_ config: inout Config,
	_ env: inout Environment,
	_ services: inout Services
) throws {
	// Register providers first
	try services.register(FluentMySQLProvider())
	try services.register(LeafProvider())
	try services.register(RedisProvider())
	try services.register(AuthenticationProvider())
	
	// Add both types of databases
	var databases = DatabaseConfig()
	databases.add(database: MySQLDatabase.self, as: .mysql)
	databases.add(database: RedisDatabase.self, as: .redis)
	services.register(databases)
	
	// Prefer using Leaf as our template renderer
	config.prefer(LeafRenderer.self, for: TemplateRenderer.self)
	
	// Add custom Leaf tags
	var leafConfig = LeafTagConfig.default()
	leafConfig.use(LineBreakTag(), as: "multiline")
	services.register(leafConfig)
	
	// Get server port with default of 8080
	let port: Int
	if let envPort = Environment.get("SERVER_PORT") {
		port = Int(envPort) ?? 8080
	}
	else {
		port = 8080
	}
	
	// Set hostname and port for server
	var serverConfig = EngineServerConfig.default(
		hostname: Environment.get("SERVER_LISTEN") ?? "0.0.0.0",
		port: port
	)
	
	// Override max body size if specified by environment
	if let envMaxBodySize = Environment.get("SERVER_MAX_BODY_SIZE"),
		let size = Int(envMaxBodySize)
	{
		serverConfig.maxBodySize = size
	}
	
	// Register server config
	services.register(serverConfig)
	
	// Register routes to the router
	let router = EngineRouter.default()
	try routes(router)
	services.register(router, as: Router.self)
	
	// Register custom MySQL config
	let mysqlConfig = MySQLDatabaseConfig(
		hostname: Environment.get("MYSQL_HOSTNAME") ?? "127.0.0.1",
		username: Environment.get("MYSQL_USER") ?? "mentor",
		password: Environment.get("MYSQL_PASSWORD") ?? "changeme",
		database: Environment.get("MYSQL_DATABASE") ?? "mentor"
	)
	services.register(mysqlConfig)
	
	// Register custom Redis config
	// XXX: https://github.com/vapor/redis/pull/99#issuecomment-382139890
//	let redisConfig = RedisClientConfig(
//		hostname: Environment.get("REDIS_HOSTNAME") ?? "127.0.0.1",
//		password: Environment.get("REDIS_PASSWORD")
//	)
	let redisHostname = Environment.get("REDIS_HOSTNAME") ?? "127.0.0.1"
	let redisConnectionString = "redis://\(redisHostname):6379"
	let redisURL = URL(string: redisConnectionString)
	let redisConfig = RedisClientConfig(url: redisURL!)
	services.register(redisConfig)
	
	
	#if false
	// Register RedisClient as a service
	// FIXME: DOESN'T WORK - https://github.com/vapor/redis/issues/98
	services.register { container -> RedisClient in
		// Evil hack to create a RedisClient synchronously
		let eventLoop = EmbeddedEventLoop()
		let syncFuture = Future<Void>.done(on: eventLoop)
		return try syncFuture.flatMap(to: RedisClient.self) {
			return container.requestConnection(to: .redis)
		}.wait()
	}
	
	// Register Redis as our preferred KeyedCache
	// FIXME: DOESN'T WORK - https://github.com/vapor/redis/issues/98
	config.prefer(RedisClient.self, for: KeyedCache.self)
	#endif
	
	
	// Register KeyedCacheSessions (now backed by Redis) as our prefered Sessions
	config.prefer(KeyedCacheSessions.self, for: Sessions.self)
	
	// Register BCryptDigest as our prefered PasswordVerifier
	config.prefer(BCryptDigest.self, for: PasswordVerifier.self)
	
	// Register middleware
	var middlewares = MiddlewareConfig() // Create _empty_ middleware config
	middlewares.use(UserAccount.authSessionsMiddleware()) // Handles user authentication sessions
	middlewares.use(SessionsMiddleware.self) // Handles session data
	middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
	middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
	middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
	services.register(middlewares)
	
	// Configure migrations
	var migrations = MigrationConfig()
	migrations.add(model: Category.self, database: .mysql)
	migrations.add(migration: PopulateCategories.self, database: .mysql)
	migrations.add(model: SampleQuestion.self, database: .mysql)
	migrations.add(migration: PopulateSampleQuestions.self, database: .mysql)
	migrations.add(model: UserAccount.self, database: .mysql)
	migrations.add(model: Mentor.self, database: .mysql)
	migrations.add(model: Mentorship.self, database: .mysql)
	migrations.add(model: Message.self, database: .mysql)
	services.register(migrations)
}

/// Allow registering a RedisClient as a service
extension RedisClient: Service { }
