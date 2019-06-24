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
//    var me: Observable<User?> { get }
    var me: User? { get }
    func fetchMe() -> Observable<Void>
}

final class UserService: UserServiceType {
    
    fileprivate let networking: GitTimeProvider<GitHubAPI>
    fileprivate let userSubject = BehaviorRelay<User?>(value: nil)
    lazy var me: User? = self.userSubject.value
    
    init(networking: GitTimeProvider<GitHubAPI>) {
        self.networking = networking
    }
    
    func fetchMe() -> Observable<Void> {
        return self.networking.rx.request(.fetchMe)
            .map(User.self)
            .asObservable()
            .do(onNext: { [weak self] user in
                self?.userSubject.accept(user)
            }).map { _ in }
    }
    
}
