import Vapor

/// Controls basic CRUD operations on `SampleQuestion`s.
final class SampleQuestionController: RouteCollection {
	func boot(router: Router) throws {
		let sampg = router.grouped("sampleQuestions")
		
		// GET /sampleQuestions
		sampg.get(use: index)
		
		// GET /sampleQuestions/:id
		sampg.get(SampleQuestion.parameter, use: get)
	}
	
	/// Returns a list of all `SampleQuestion`s.
	func index(_ req: Request) throws -> Future<[SampleQuestion]> {
		return SampleQuestion.query(on: req).all()
	}
	
	/// Returns an individual `SampleQuestion`.
	func get(_ req: Request) throws -> Future<SampleQuestion> {
		return try req.parameter(SampleQuestion.self)
	}
}
