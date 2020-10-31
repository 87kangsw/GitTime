//
//  UserService.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxCocoa
import RxSwift

protocol UserServiceType {
	func fetchMe() -> Observable<Me>
}

final class UserService: UserServiceType {
    
    fileprivate let networking: GitTimeProvider<GitHubAPI>
	
    init(networking: GitTimeProvider<GitHubAPI>) {
        self.networking = networking
    }
    
    func fetchMe() -> Observable<Me> {
        return self.networking.request(.fetchMe)
            .map(Me.self)
            .asObservable()
            .do(onNext: { user in
				GlobalStates.shared.currentUser.accept(user)
            })
    }
}
