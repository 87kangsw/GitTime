//
//  Fixture.swift
//  GitTimeTests
//
//  Created by Kanz on 2020/10/25.
//

import Foundation
import Immutable

func fixture<T: Decodable>(_ json: [String: Any?]) -> T {
	do {
		let data = try JSONSerialization.data(withJSONObject: json.filterNil(), options: [])
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return try decoder.decode(T.self, from: data)
	} catch {
		fatalError(String(describing: error))
	}
}

