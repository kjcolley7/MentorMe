import FluentMySQL
import Vapor

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
	
	// Register custom MySQL Config
	let mysqlConfig = MySQLDatabaseConfig(
		hostname: Environment.get("MYSQL_HOSTNAME") ?? "127.0.0.1",
		port: 3306,
		username: Environment.get("MYSQL_USER") ?? "mentor",
		password: Environment.get("MYSQL_PASSWORD") ?? "changeme",
		database: Environment.get("MYSQL_DATABASE") ?? "mentor"
	)
	services.register(mysqlConfig)
	
	// Register middleware
	var middlewares = MiddlewareConfig() // Create _empty_ middleware config
	// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
	middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
	middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
	services.register(middlewares)
	
	// Configure migrations
	var migrations = MigrationConfig()
	migrations.add(model: Category.self, database: .mysql)
	migrations.add(migration: DefaultCategories.self, database: .mysql)
	services.register(migrations)
}
