//
//  SpokenLanguage.swift
//  GitTime
//
//  Created by Kanz on 2020/12/22.
//

import Foundation

struct SpokenLanguage: ModelType, Identifiable {
	var id: String
	var name: String
	
	enum CodingKeys: String, CodingKey {
		case id = "code"
		case name = "name"
	}
}
