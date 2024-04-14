//
//  GitTimeDecodingError.swift
//  GitTime
//
//  Created by Kanz on 4/13/24.
//

// https://gist.github.com/nunogoncalves/4852077f4e576872f72b70d9e79942f3

import Foundation

import Moya

extension Error {
	var decodingErrorInfo: DecodingErrorInfomation? {
		if let moyaError = self as? MoyaError {
			if case .objectMapping(let error, let response) = moyaError {
				if let decodeError = error as? DecodingError,
					let path = response.request?.url?.getPath() {
					return DecodingErrorInfomation(
						path: path,
						error: GitTimeDecodingError(with: decodeError)
					)
				}
			}
		}
		return nil
	}
}

struct DecodingErrorInfomation {
	let path: String
	let error: GitTimeDecodingError
}

enum GitTimeDecodingError: CustomStringConvertible {
	case dataCorrupted(_ message: String)
	case keyNotFound(_ message: String)
	case typeMismatch(_ message: String)
	case valueNotFound(_ message: String)
	case any(_ error: Error)
	
	init(with error: DecodingError) {
		switch error {
		case let .dataCorrupted(context):
			let debugDescription = (context.underlyingError as NSError?)?.userInfo["NSDebugDescription"] ?? ""
			self = .dataCorrupted("Data corrupted. \(context.debugDescription) \(debugDescription)")
		case let .keyNotFound(key, context):
			self = .keyNotFound("Key not found. Expected -> \(key.stringValue) <- at: \(context.prettyPath())")
		case let .typeMismatch(_, context):
			self = .typeMismatch("Type mismatch. \(context.debugDescription), at: \(context.prettyPath())")
		case let .valueNotFound(_, context):
			self = .valueNotFound("Value not found. -> \(context.prettyPath()) <- \(context.debugDescription)")
		default:
			self = .any(error)
		}
	}
	var description: String {
		switch self {
		case let .dataCorrupted(message), let .keyNotFound(message), let .typeMismatch(message), let .valueNotFound(message):
			return message
		case let .any(error):
			return error.localizedDescription
		}
	}
}

extension DecodingError.Context {
	func prettyPath(separatedBy separator: String = ".") -> String {
		codingPath.map { $0.stringValue }.joined(separator: ".")
	}
}

extension URL {
	func getPath() -> String? {
		let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
		return components?.path
	}
}
