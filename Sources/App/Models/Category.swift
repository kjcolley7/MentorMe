//
//  Category.swift
//  App
//
//  Created by Kevin Colley on 4/13/18.
//

import FluentMySQL

final class Category: MySQLModel {
	var id: Int?
	var name: String
	
	init(id: Int? = nil, name: String) {
		self.id = id
		self.name = name
	}
}

extension Category: Migration { }
