import Leaf

struct LineBreakTag: TagRenderer {
	func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
		let printer = Print()
		return try printer.render(tag: tag).map { printed in
			let escaped = printed.string ?? ""
			return .string(
				escaped.replacingOccurrences(of: "\r", with: "")
					.replacingOccurrences(of: "\n", with: "<br/>")
			)
		}
	}
}
