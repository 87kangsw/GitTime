//
//  Language.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct Language: Decodable {
    let id: Int
    let name: String
    let type: LanguageTypes
    let color: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = LanguageTypes(rawValue: try container.decode(String.self, forKey: .type)) ?? .programming
        color = try container.decode(String.self, forKey: .color)
    }
    
    init(name: String) {
        self.id = 0
        self.name = name
        self.type = LanguageTypes.all
        self.color = ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case color
    }
    
    static var allLanguage: Language {
        return Language(name: "All Languages")
    }
}
