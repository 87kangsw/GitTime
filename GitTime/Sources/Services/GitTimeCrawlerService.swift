//
//  GitTimeCrawlerService.swift
//  GitTime
//
//  Created by Kanz on 14/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxSwift

protocol GitTimeCrawlerServiceType: class {
    func fetchTrendingRepositories(language: String?, period: String?) -> Observable<[TrendRepo]>
    func fetchTrendingDevelopers(language: String?, period: String?) -> Observable<[TrendDeveloper]>
    func fetchContributions(userName: String) -> Observable<ContributionInfo>
}

class GitTimeCrawlerService: GitTimeCrawlerServiceType {
    
    fileprivate let networking: GitTimeProvider<GitTimeCrawlerAPI>
    
    init(networking: GitTimeProvider<GitTimeCrawlerAPI>) {
        self.networking = networking
    }
    
    func fetchTrendingRepositories(language: String?, period: String?) -> Observable<[TrendRepo]> {
        return self.networking.rx.request(.trendingRepositories(language: language, period: period))
            .map([TrendRepo].self)
            .asObservable()
    }
    
    func fetchTrendingDevelopers(language: String?, period: String?) -> Observable<[TrendDeveloper]> {
        return self.networking.rx.request(.trendingDevelopers(language: language, period: period))
            .map([TrendDeveloper].self)
            .asObservable()
    }
    
    func fetchContributions(userName: String) -> Observable<ContributionInfo> {
        return self.networking.rx.request(.fetchContributions(userName: userName))
            .map(ContributionInfo.self)
            .asObservable()
    }
}
