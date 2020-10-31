//
//  SplashViewControllerSpec.swift
//  GitTime
//
//  Created by Kanz on 2020/10/13.
//  
//

import Quick
import Nimble

@testable import GitTime

class SplashViewControllerSpec: QuickSpec {
    override func spec() {

		var keychainService: StubKeychainService!
		var userService: StubUserService!
		var reactor: SplashViewReactor!
		var viewController: SplashViewController!
		
		beforeEach {
			keychainService = StubKeychainService()
			userService = StubUserService()
		}
		
		// 1.
		describe("스플래시 화면") {
			context("viewDidAppear에서") {
				it("checkAuthentication Action을 호출한다") {
					reactor = SplashViewReactor(keychainService: keychainService, userService: userService)
					reactor.isStubEnabled = true
					
					viewController = SplashViewController(reactor: reactor,
														  goToLoginScreen: {},
														  goToMainScreen: {})
					_ = viewController.view
					
					viewController.viewDidAppear(false)
					expect(reactor.stub.actions.last).to(equal(.checkAuthentication))
				}
			}
		}
		
		// 2.
		describe("스플래시 화면") {
			var isExcutedLoginScreen: Bool!
			var isExcutedMainScreen: Bool!
			
			beforeEach {
				isExcutedLoginScreen = false
				isExcutedMainScreen = false
				
				reactor = SplashViewReactor(keychainService: keychainService, userService: userService)
				reactor.isStubEnabled = true
				
				viewController = SplashViewController(reactor: reactor,
													  goToLoginScreen: { isExcutedLoginScreen = true },
													  goToMainScreen: { isExcutedMainScreen = true })
				_ = viewController.view
			}
			
			//
			context("인증이 성공한 경우") {
				beforeEach {
					reactor.stub.state.value.isAutheticated = true
				}
				
				it("로그인 화면은 present되지 않아야 한다") {
					expect(isExcutedLoginScreen).to(beFalse())
				}
				
				it("메인 화면을 present 한다") {
					expect(isExcutedMainScreen).to(beTrue())
				}
			}
			
			//
			context("인증이 실패한 경우") {
				beforeEach {
					reactor.stub.state.value.isAutheticated = false
				}
				
				it("로그인 화면은 present 한다") {
					expect(isExcutedLoginScreen).to(beTrue())
				}
				
				it("메인 화면을 present되지 않아야 한다") {
					expect(isExcutedMainScreen).to(beFalse())
				}
			}
		}
    }
}
