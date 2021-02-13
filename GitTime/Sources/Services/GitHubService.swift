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
}
