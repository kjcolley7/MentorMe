import Vapor

enum AlertType: String {
	case primary
	case secondary
	case success
	case danger
	case warning
	case info
	case light
	case dark
}

extension AlertType: Content { }

struct Alert: Content {
	let type: AlertType
	let message: String
	
	init(_ type: AlertType, message: String) {
		self.type = type
		self.message = message
	}
}

extension Alert: Error { }

extension Abort {
	var alert: Alert? {
		guard !reason.isEmpty else {
			return nil
		}
		
		let type: AlertType
		switch status.code {
			case 100..<400:
				type = .info
			
			case 400..<600: fallthrough
			default:
				type = .danger
		}
		
		return Alert(type, message: reason)
	}
}

extension Alert {
	static func fromError(_ error: Error) -> Alert? {
		switch error {
		case let alert as Alert:
			return alert
			
		case let abort as Abort:
			return abort.alert
			
		default:
			return Alert(.danger, message: error.localizedDescription)
		}
	}
}
