//
//  StubGlobalStates.swift
//  GitTimeTests
//
//  Created by Kanz on 2020/10/14.
//

import Foundation

import RxSwift

@testable import GitTime

final class StubGlobalStates {
	
	static let shared = StubGlobalStates()
	
	// Current User
	let userSubject = ReplaySubject<Me?>.create(bufferSize: 1)
	lazy var currentUser: Observable<Me?> = self.userSubject.asObservable()
		.startWith(nil)
		.share(replay: 1)
	
	// Current Access Token
	var currentAccessToken: String?
}
