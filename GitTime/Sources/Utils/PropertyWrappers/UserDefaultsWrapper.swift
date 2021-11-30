//
//  UserDefaultsWrapper.swift
//  GitTime
//
//  Created by Kanz on 2020/09/29.
//

import Foundation

@propertyWrapper struct UserDefaultsWrapper<T> {
	let key: String
	let defaultValue: T
	
	init(_ key: String, defaultValue: T) {
		self.key = key
		self.defaultValue = defaultValue
	}
	
	var wrappedValue: T {
		get {
			return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
		}
		set {
			if let value = newValue as? OptionalProtocol, value.isNil() {
				UserDefaults.standard.removeObject(forKey: key)
			} else {
				UserDefaults.standard.set(newValue, forKey: key)
			}
		}
	}
}
 
private protocol OptionalProtocol {
	func isNil() -> Bool
}

extension Optional: OptionalProtocol {
	func isNil() -> Bool {
		return self == nil
	}
}
