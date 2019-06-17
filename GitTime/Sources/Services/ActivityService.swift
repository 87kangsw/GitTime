//
//  ActivityService.swift
//  GitTime
//
//  Created by Kanz on 10/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxSwift

protocol ActivityServiceType {
    func fetchActivities(userName: String, page: Int) -> Observable<[Event]>
}

class ActivityService: ActivityServiceType {
    
    fileprivate let networking: GitTimeProvider<GitHubAPI>
    
    init(networking: GitTimeProvider<GitHubAPI>) {
        self.networking = networking
    }
    
    func fetchActivities(userName: String, page: Int) -> Observable<[Event]> {
        return self.networking.rx.request(.activityEvent(userName: userName, page: page))
            .map([Event].self)
            .asObservable()
    }
}
