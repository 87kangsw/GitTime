//
//  StubKeychainService.swift
//  GitTimeTests
//
//  Created by Kanz on 2020/10/13.
//

import RxSwift
import Stubber

@testable import GitTime

final class StubKeychainService: KeychainServiceType {
	func getAccessToken() -> String? {
		return "ABCD-EFADFG-GITTIME"
	}
	
	func setAccessToken(_ token: String) throws {
		try Stubber.invoke(setAccessToken, args: token)
	}
	
	func removeAccessToken() throws {
		try Stubber.invoke(removeAccessToken, args: ())
	}
}
