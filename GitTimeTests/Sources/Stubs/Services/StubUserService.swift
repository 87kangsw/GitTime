//
//  StubUserService.swift
//  GitTimeTests
//
//  Created by Kanz on 2020/10/14.
//

import RxSwift
import Stubber

@testable import GitTime

final class StubUserService: UserServiceType {
	func fetchMe() -> Observable<Me> {
		Stubber.invoke(fetchMe, args: (), default: .never())
	}
}
