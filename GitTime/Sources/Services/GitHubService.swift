//
//  GitHubService.swift
//  GitTime
//
//  Created by Kanz on 2020/10/27.
//

import Moya
import RxSwift

protocol GitHubServiceType {
	
	// Contributors
	func contributors() -> Observable<[User]>
	
	// UserInfo
	func userInfo(userName: String) -> Observable<User>
}

final class GitHubService: GitHubServiceType {
	
	fileprivate let networking: GitTimeProvider<GitHubAPI>
	
	init(networking: GitTimeProvider<GitHubAPI>) {
		self.networking = networking
	}
	
	// MARK: Contributor API
	
	func contributors() -> Observable<[User]> {
		self.networking.request(.contributors)
			.map([User].self)
			.asObservable()
	}
	
	// MARK: UserInfo (exist)
	func userInfo(userName: String) -> Observable<User> {
		self.networking.request(.userInfo(userName: userName))
			.map(User.self)
			.asObservable()
	}
}
