//
//  Matchers.swift
//  GitTimeTests
//
//  Created by Kanz on 2020/09/30.
//

import Nimble

extension Expectation {
	func to<U>(_ matcher: (@escaping (T) -> U) -> Predicate<T>, _ predicate: @escaping (T) -> U) {
		self.to(matcher(predicate))
	}
	
	func to<U>(_ matcher: (@escaping (T.Iterator.Element) -> U) -> Predicate<T>, _ predicate: @escaping (T.Iterator.Element) -> U) where T: Sequence {
		self.to(matcher(predicate))
	}
}

func match<T>(_ closure: @escaping (T) -> Bool) -> Predicate<T> {
	return Predicate { actualExpression in
		guard let actualValue = try actualExpression.evaluate() else {
			return PredicateResult(status: .fail, message: .fail("Found nil"))
		}
		return PredicateResult(
			status: closure(actualValue) ? .matches : .doesNotMatch,
			message: .fail("got <\(actualValue)>")
		)
	}
}

func contain<T>(_ closure: @escaping (T.Iterator.Element) -> Bool) -> Predicate<T> where T: Sequence {
	return Predicate { actualExpression in
		guard let actualValue = try actualExpression.evaluate() else {
			return PredicateResult(status: .fail, message: .fail("Found nil"))
		}
		return PredicateResult(
			bool: actualValue.contains(where: closure),
			message: .fail("got <\(actualValue)>")
		)
	}
}
