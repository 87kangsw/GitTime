//
//  PlistWrapper.swift
//  GitTime
//
//  Created by Kanz on 2020/10/02.
//

import Foundation

@propertyWrapper struct PlistWrapper<T: Decodable> {
	var fileName: String

	var wrappedValue: T? {
		/*
		guard let plistPath = Bundle.main.path(forResource: "GitHub-Info", ofType: "plist"),
			let plist = NSDictionary(contentsOfFile: plistPath) as? [String: String] else {
				return [:]
		}
		return plist
		*/
		guard let plistPath = Bundle.main.path(forResource: fileName, ofType: "plist") else { return nil }
		
		do {
			let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))
			let result: T = try JSONDecoder().decode(T.self, from: data)
			return result
		} catch {
			log.error(error.localizedDescription)
			return nil
		}
	}
}
