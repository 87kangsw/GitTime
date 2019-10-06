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
        return self.networking.request(.trendingRepositories(language: language, period: period)) 
            .map([TrendRepo].self)
            .asObservable()
    }
    
    func fetchTrendingDevelopers(language: String?, period: String?) -> Observable<[TrendDeveloper]> {
        return self.networking.request(.trendingDevelopers(language: language, period: period))
            .map([TrendDeveloper].self)
            .asObservable()
    }
    
    func fetchContributions(userName: String) -> Observable<ContributionInfo> {
        var isDarkMode = false
        if #available(iOS 13.0, *) {
            let style = UIScreen.main.traitCollection.userInterfaceStyle
            isDarkMode = style == .dark
        }
         
        return self.networking.request(.fetchContributions(userName: userName,
                                                           darkMode: isDarkMode))
            .map(ContributionInfo.self)
            .asObservable()
    }
}
