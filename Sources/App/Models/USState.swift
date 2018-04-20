import Vapor

enum USState: Int {
	case AL = 1, AK, AZ, AR, CA, CO, CT, DE, FL, GA,
	     HI, ID, IL, IN, IA, KS, KY, LA, ME, MD,
	     MA, MI, MN, MS, MO, MT, NE, NV, NH, NJ,
	     NM, NY, NC, ND, OH, OK, OR, PA, RI, SC,
	     SD, TN, TX, UT, VT, VA, WA, WV, WI, WY
}

extension USState: Content { }

struct USStateContent: Content {
	let id: USState
	let abbreviation: String
	let name: String
	
	static let all: [USStateContent] = [
		USStateContent(id: .AL, abbreviation: "AL", name: "Alabama"),
		USStateContent(id: .AK, abbreviation: "AK", name: "Alaska"),
		USStateContent(id: .AZ, abbreviation: "AZ", name: "Arizona"),
		USStateContent(id: .AR, abbreviation: "AR", name: "Arkansas"),
		USStateContent(id: .CA, abbreviation: "CA", name: "California"),
		USStateContent(id: .CO, abbreviation: "CO", name: "Colorado"),
		USStateContent(id: .CT, abbreviation: "CT", name: "Connecticut"),
		USStateContent(id: .DE, abbreviation: "DE", name: "Delaware"),
		USStateContent(id: .FL, abbreviation: "FL", name: "Florida"),
		USStateContent(id: .GA, abbreviation: "GA", name: "Georgia"),
		USStateContent(id: .HI, abbreviation: "HI", name: "Hawaii"),
		USStateContent(id: .ID, abbreviation: "ID", name: "Idaho"),
		USStateContent(id: .IL, abbreviation: "IL", name: "Illinois"),
		USStateContent(id: .IN, abbreviation: "IN", name: "Indiana"),
		USStateContent(id: .IA, abbreviation: "IA", name: "Iowa"),
		USStateContent(id: .KS, abbreviation: "KS", name: "Kansas"),
		USStateContent(id: .KY, abbreviation: "KY", name: "Kentucky"),
		USStateContent(id: .LA, abbreviation: "LA", name: "Louisiana"),
		USStateContent(id: .ME, abbreviation: "ME", name: "Maine"),
		USStateContent(id: .MD, abbreviation: "MD", name: "Maryland"),
		USStateContent(id: .MA, abbreviation: "MA", name: "Massachusetts"),
		USStateContent(id: .MI, abbreviation: "MI", name: "Michigan"),
		USStateContent(id: .MN, abbreviation: "MN", name: "Minnesota"),
		USStateContent(id: .MS, abbreviation: "MS", name: "Mississippi"),
		USStateContent(id: .MO, abbreviation: "MO", name: "Missouri"),
		USStateContent(id: .MT, abbreviation: "MT", name: "Montana"),
		USStateContent(id: .NE, abbreviation: "NE", name: "Nebraska"),
		USStateContent(id: .NV, abbreviation: "NV", name: "Nevada"),
		USStateContent(id: .NH, abbreviation: "NH", name: "New Hampshire"),
		USStateContent(id: .NJ, abbreviation: "NJ", name: "New Jersey"),
		USStateContent(id: .NM, abbreviation: "NM", name: "New Mexico"),
		USStateContent(id: .NY, abbreviation: "NY", name: "New York"),
		USStateContent(id: .NC, abbreviation: "NC", name: "North Carolina"),
		USStateContent(id: .ND, abbreviation: "ND", name: "North Dakota"),
		USStateContent(id: .OH, abbreviation: "OH", name: "Ohio"),
		USStateContent(id: .OK, abbreviation: "OK", name: "Oklahoma"),
		USStateContent(id: .OR, abbreviation: "OR", name: "Oregon"),
		USStateContent(id: .PA, abbreviation: "PA", name: "Pennsylvania"),
		USStateContent(id: .RI, abbreviation: "RI", name: "Rhode Island"),
		USStateContent(id: .SC, abbreviation: "SC", name: "South Carolina"),
		USStateContent(id: .SD, abbreviation: "SD", name: "South Dakota"),
		USStateContent(id: .TN, abbreviation: "TN", name: "Tennessee"),
		USStateContent(id: .TX, abbreviation: "TX", name: "Texas"),
		USStateContent(id: .UT, abbreviation: "UT", name: "Utah"),
		USStateContent(id: .VT, abbreviation: "VT", name: "Vermont"),
		USStateContent(id: .VA, abbreviation: "VA", name: "Virginia"),
		USStateContent(id: .WA, abbreviation: "WA", name: "Washington"),
		USStateContent(id: .WV, abbreviation: "WV", name: "West Virginia"),
		USStateContent(id: .WI, abbreviation: "WI", name: "Wisconsin"),
		USStateContent(id: .WY, abbreviation: "WY", name: "Wyoming")
	]
}

extension USState {
	var content: USStateContent {
		switch self {
			case .AL: return USStateContent(id: self, abbreviation: "AL", name: "Alabama")
			case .AK: return USStateContent(id: self, abbreviation: "AK", name: "Alaska")
			case .AZ: return USStateContent(id: self, abbreviation: "AZ", name: "Arizona")
			case .AR: return USStateContent(id: self, abbreviation: "AR", name: "Arkansas")
			case .CA: return USStateContent(id: self, abbreviation: "CA", name: "California")
			case .CO: return USStateContent(id: self, abbreviation: "CO", name: "Colorado")
			case .CT: return USStateContent(id: self, abbreviation: "CT", name: "Connecticut")
			case .DE: return USStateContent(id: self, abbreviation: "DE", name: "Delaware")
			case .FL: return USStateContent(id: self, abbreviation: "FL", name: "Florida")
			case .GA: return USStateContent(id: self, abbreviation: "GA", name: "Georgia")
			case .HI: return USStateContent(id: self, abbreviation: "HI", name: "Hawaii")
			case .ID: return USStateContent(id: self, abbreviation: "ID", name: "Idaho")
			case .IL: return USStateContent(id: self, abbreviation: "IL", name: "Illinois")
			case .IN: return USStateContent(id: self, abbreviation: "IN", name: "Indiana")
			case .IA: return USStateContent(id: self, abbreviation: "IA", name: "Iowa")
			case .KS: return USStateContent(id: self, abbreviation: "KS", name: "Kansas")
			case .KY: return USStateContent(id: self, abbreviation: "KY", name: "Kentucky")
			case .LA: return USStateContent(id: self, abbreviation: "LA", name: "Louisiana")
			case .ME: return USStateContent(id: self, abbreviation: "ME", name: "Maine")
			case .MD: return USStateContent(id: self, abbreviation: "MD", name: "Maryland")
			case .MA: return USStateContent(id: self, abbreviation: "MA", name: "Massachusetts")
			case .MI: return USStateContent(id: self, abbreviation: "MI", name: "Michigan")
			case .MN: return USStateContent(id: self, abbreviation: "MN", name: "Minnesota")
			case .MS: return USStateContent(id: self, abbreviation: "MS", name: "Mississippi")
			case .MO: return USStateContent(id: self, abbreviation: "MO", name: "Missouri")
			case .MT: return USStateContent(id: self, abbreviation: "MT", name: "Montana")
			case .NE: return USStateContent(id: self, abbreviation: "NE", name: "Nebraska")
			case .NV: return USStateContent(id: self, abbreviation: "NV", name: "Nevada")
			case .NH: return USStateContent(id: self, abbreviation: "NH", name: "New Hampshire")
			case .NJ: return USStateContent(id: self, abbreviation: "NJ", name: "New Jersey")
			case .NM: return USStateContent(id: self, abbreviation: "NM", name: "New Mexico")
			case .NY: return USStateContent(id: self, abbreviation: "NY", name: "New York")
			case .NC: return USStateContent(id: self, abbreviation: "NC", name: "North Carolina")
			case .ND: return USStateContent(id: self, abbreviation: "ND", name: "North Dakota")
			case .OH: return USStateContent(id: self, abbreviation: "OH", name: "Ohio")
			case .OK: return USStateContent(id: self, abbreviation: "OK", name: "Oklahoma")
			case .OR: return USStateContent(id: self, abbreviation: "OR", name: "Oregon")
			case .PA: return USStateContent(id: self, abbreviation: "PA", name: "Pennsylvania")
			case .RI: return USStateContent(id: self, abbreviation: "RI", name: "Rhode Island")
			case .SC: return USStateContent(id: self, abbreviation: "SC", name: "South Carolina")
			case .SD: return USStateContent(id: self, abbreviation: "SD", name: "South Dakota")
			case .TN: return USStateContent(id: self, abbreviation: "TN", name: "Tennessee")
			case .TX: return USStateContent(id: self, abbreviation: "TX", name: "Texas")
			case .UT: return USStateContent(id: self, abbreviation: "UT", name: "Utah")
			case .VT: return USStateContent(id: self, abbreviation: "VT", name: "Vermont")
			case .VA: return USStateContent(id: self, abbreviation: "VA", name: "Virginia")
			case .WA: return USStateContent(id: self, abbreviation: "WA", name: "Washington")
			case .WV: return USStateContent(id: self, abbreviation: "WV", name: "West Virginia")
			case .WI: return USStateContent(id: self, abbreviation: "WI", name: "Wisconsin")
			case .WY: return USStateContent(id: self, abbreviation: "WY", name: "Wyoming")
		}
	}
	
	static func fromAbbreviation(_ abbrev: String) -> USState? {
		switch abbrev.uppercased() {
			case "AL": return .AL
			case "AK": return .AK
			case "AZ": return .AZ
			case "AR": return .AR
			case "CA": return .CA
			case "CO": return .CO
			case "CT": return .CT
			case "DE": return .DE
			case "FL": return .FL
			case "GA": return .GA
			case "HI": return .HI
			case "ID": return .ID
			case "IL": return .IL
			case "IN": return .IN
			case "IA": return .IA
			case "KS": return .KS
			case "KY": return .KY
			case "LA": return .LA
			case "ME": return .ME
			case "MD": return .MD
			case "MA": return .MA
			case "MI": return .MI
			case "MN": return .MN
			case "MS": return .MS
			case "MO": return .MO
			case "MT": return .MT
			case "NE": return .NE
			case "NV": return .NV
			case "NH": return .NH
			case "NJ": return .NJ
			case "NM": return .NM
			case "NY": return .NY
			case "NC": return .NC
			case "ND": return .ND
			case "OH": return .OH
			case "OK": return .OK
			case "OR": return .OR
			case "PA": return .PA
			case "RI": return .RI
			case "SC": return .SC
			case "SD": return .SD
			case "TN": return .TN
			case "TX": return .TX
			case "UT": return .UT
			case "VT": return .VT
			case "VA": return .VA
			case "WA": return .WA
			case "WV": return .WV
			case "WI": return .WI
			case "WY": return .WY
			default: return nil
		}
	}
}
