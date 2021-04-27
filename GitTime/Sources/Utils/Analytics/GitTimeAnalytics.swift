//
//  GitTimeAnalytics.swift
//  GitTime
//
//  Created by Kanz on 2020/03/12.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import FirebaseAnalytics

final class GitTimeAnalytics {
    
    static let shared = GitTimeAnalytics()
    
    func logEvent(key: String, parameters: [String: Any]?) {
        Analytics.logEvent(key, parameters: parameters)
    }
    
    func setScreenName(screenName: String) {
		Analytics.logEvent(AnalyticsEventScreenView, parameters: nil)
    }
    
    func setUserIdentifier(identifiler: String) {
        Analytics.setUserID(identifiler)
    }
    
    func setUserProperty(value: String?, key: String) {
        Analytics.setUserProperty(value, forName: key)
    }
}
