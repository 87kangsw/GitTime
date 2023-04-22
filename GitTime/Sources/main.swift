//
//  main.swift
//  GitTime
//
//  Created by Kanz on 2020/09/30.
//

import UIKit
/*
private func appDelegateClassName() -> String {
	let isTesting = NSClassFromString("XCTestCase") != nil
	return isTesting ? "GitTimeTests.StubAppDelegate" : NSStringFromClass(AppDelegate.self)
}
*/
private func appDelegateClassName() -> String {
	NSStringFromClass(AppDelegate.self)
}

UIApplicationMain(
	CommandLine.argc,
	CommandLine.unsafeArgv,
	NSStringFromClass(UIApplication.self),
	appDelegateClassName()
)
