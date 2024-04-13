//
//  ActivityService.swift
//  GitTime
//
//  Created by Kanz on 10/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

import RxSwift

protocol ActivityServiceType {
    func fetchActivities(userName: String, page: Int) -> Observable<[Event]>
    func trialActivities() -> Observable<[Event]>
}

class ActivityService: ActivityServiceType {
    
    fileprivate let networking: GitTimeProvider<GitHubAPI>
    
    init(networking: GitTimeProvider<GitHubAPI>) {
        self.networking = networking
    }
    
    func fetchActivities(userName: String, page: Int) -> Observable<[Event]> {
        return self.networking.request(.activityEvent(userName: userName, page: page))
            .map([Event].self)
			.do(onError: { error in
				if let decodingErrorInfo = error.decodingErrorInfo {
					log.error(decodingErrorInfo)
				}
			})
            .asObservable()
    }
    
    func trialActivities() -> Observable<[Event]> {
        guard let activities: [Event] = Bundle.resource(name: "events", extensionType: "json") else { return .empty() }
        return .just(activities)
    }
}
