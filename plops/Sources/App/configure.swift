import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateCheckpoints())
    app.migrations.add(CreateRunners())
    app.migrations.add(CreateRunnerEvents())
    
    // ⚠️ this is just to reset the db for testing/dev work. Remove it. ⚠️
    try app.autoRevert().wait()
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}


///
/// Start a Docker container running Postgres:
/// docker run --name postgres -e POSTGRES_DB=vapor_database -e POSTGRES_USER=vapor_username -e POSTGRES_PASSWORD=vapor_password -p 5432:5432 -d postgres
/// 
