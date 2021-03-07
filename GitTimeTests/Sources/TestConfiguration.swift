//
//  TestConfiguration.swift
//  GitTimeTests
//
//  Created by Kanz on 2020/09/30.
//

import Quick
import Stubber

@testable import GitTime

class TestConfiguration: QuickConfiguration {
	override class func configure(_ configuration: Configuration) {
		configuration.beforeEach {
			Stubber.clear()
			UIApplication.shared.delegate = StubAppDelegate()
		}
		
		configuration.afterEach {
			Stubber.clear()
		}
	}
}
