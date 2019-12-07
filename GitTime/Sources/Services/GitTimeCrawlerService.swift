//
//  GitTimeCrawlerService.swift
//  GitTime
//
//  Created by Kanz on 14/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxSwift
import Moya

protocol GitTimeCrawlerServiceType: class {
    func fetchTrendingRepositories(language: String?, period: String?) -> Observable<[TrendRepo]>
    func fetchTrendingDevelopers(language: String?, period: String?) -> Observable<[TrendDeveloper]>
    func fetchContributions(userName: String) -> Observable<ContributionInfo>
    func fetchContributionsRawdata(userName: String) -> Observable<Response>
    func fetchTrialContributions() -> Observable<ContributionInfo>
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
    
    func fetchContributionsRawdata(userName: String) -> Observable<Response> {
        
        var isDarkMode = false
        
        if #available(iOS 13.0, *) {
            let style = UIScreen.main.traitCollection.userInterfaceStyle
            isDarkMode = style == .dark
        }
        
        return self.networking.request(.fetchContributionsRawdata(userName: userName,
                                                                darkMode: isDarkMode))
        .asObservable()
    }
    
    func fetchTrialContributions() -> Observable<ContributionInfo> {
        var isDarkMode = false
        if #available(iOS 13.0, *) {
            let style = UIScreen.main.traitCollection.userInterfaceStyle
            isDarkMode = style == .dark
        }
        
        let json: String = isDarkMode ? "contributions_dark" : "contributions_light"
        guard let contribution: ContributionInfo = Bundle.resource(name: json, extensionType: "json") else { return .empty() }
        return .just(contribution)
    }
}
