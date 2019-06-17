//
//  AppStoreService.swift
//  GitTime
//
//  Created by Kanz on 07/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxSwift

protocol AppStoreServiceType {
    func getLatestVersion() -> Observable<AppVersion>
}

class AppStoreService: AppStoreServiceType {
    
    fileprivate let networking: GitTimeProvider<AppStoreAPI>
    
    init(networking: GitTimeProvider<AppStoreAPI>) {
        self.networking = networking
    }
    
    func getLatestVersion() -> Observable<AppVersion> {
        guard let bundleID = AppInfo.shared.bundleID else { return .empty() }
        return self.networking.rx.request(.lookUp(bundleID: bundleID))
            .map(AppVersion.self)
            .asObservable()
    }
}
