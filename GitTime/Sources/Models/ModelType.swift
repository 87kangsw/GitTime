//
//  ModelType.swift
//  GitTime
//
//  Created by Kanz on 15/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

protocol ModelType: Codable {
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}

extension ModelType {
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        return .iso8601
    }
    
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = self.dateDecodingStrategy
        return decoder
    }
}
