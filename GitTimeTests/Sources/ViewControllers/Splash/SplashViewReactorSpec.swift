//
//  SplashViewReactorSpec.swift
//  GitTime
//
//  Created by Kanz on 2020/10/13.
//  
//

import Quick
import Nimble
import Stubber

@testable import GitTime

class SplashViewReactorSpec: QuickSpec {
    override func spec() {
		var keychainService: StubKeychainService!
		var userService: StubUserService!
		
		var reactor: SplashViewReactor!
		
		// InitialState
		beforeEach {
			keychainService = StubKeychainService()
			userService = StubUserService()
			
			reactor = SplashViewReactor(keychainService: keychainService,
										userService: userService)
			_ = reactor.state
		}
		
		// 1.
		describe("initialState 확인") {
			it("isAutheticated는 최초 nil이어야 한다") {
				expect(reactor.currentState.isAutheticated).to(beNil())
			}
		}
		
		// 2.
//		describe("checkAuthentication는") {
//			context("keychain에 토큰이 있는 경우") {
//				it("fetch me를 호출한다") {
//					Stubber.register(userService.fetchMe) { .just(MeFixture.kanz) }
//					reactor.action.onNext(.checkAuthentication)
//					expect(reactor.currentState.isAutheticated) == true
//				}
//			}
//
//			context("keychain에 토큰이 없는 경우") {
//				it("isAutheticated는 false여야 한다") {
//					Stubber.register(userService.fetchMe) { .error(StubError()) }
//					reactor.action.onNext(.checkAuthentication)
//					expect(reactor.currentState.isAutheticated) == false
//				}
//			}
//		}
    }
}
