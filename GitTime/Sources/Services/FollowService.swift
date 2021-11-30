//
//  FollowService.swift
//  GitTime
//
//  Created by Kanz on 04/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxSwift

protocol FollowServiceType: AnyObject {
    func fetchFollowers(userName: String, page: Int) -> Observable<[User]>
    func fetchFollowing(userName: String, page: Int) -> Observable<[User]>
    func trialFollow() -> Observable<[User]>
}

class FollowService: FollowServiceType {
    
    fileprivate let networking: GitTimeProvider<GitHubAPI>
    
    init(networking: GitTimeProvider<GitHubAPI>) {
        self.networking = networking
    }
    
    func fetchFollowers(userName: String, page: Int) -> Observable<[User]> {
        return self.networking.request(.followers(userName: userName, page: page))
            .map([User].self)
            .asObservable()
    }
    
    func fetchFollowing(userName: String, page: Int) -> Observable<[User]> {
        return self.networking.request(.following(userName: userName, page: page))
            .map([User].self)
            .asObservable()
    }
    
    func trialFollow() -> Observable<[User]> {
        guard let follow: [User] = Bundle.resource(name: "follow", extensionType: "json") else { return .empty() }
        return .just(follow)
    }
}
