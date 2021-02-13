//
//  TrendViewReactor.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift
import Moya
import Kanna

final class TrendViewReactor: Reactor {
    
    enum Action {
        case refresh
        case selectPeriod(PeriodTypes)
        //        case selectLanguage(String?)
        case selectLanguage(Language?)
        case switchSegmentControl
        case requestTrending
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setPeriod(PeriodTypes)
        //        case setLanguage(String?)
        case setLanguage(Language?)
        case setTrendType(TrendTypes)
        case fetchRepositories([TrendRepo])
        case fetchDevelopers([TrendDeveloper])
    }
    
    struct State {
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var period: PeriodTypes
        var language: Language?
        var trendingType: TrendTypes
        var repositories: [TrendSectionItem] = []
        var developers: [TrendSectionItem] = []
        var trendSections: [TrendSection] {
            switch self.trendingType {
            case .repositories:
                guard !self.isRefreshing else {
                    return [.repo([])]
                }
//                guard !self.repositories.isEmpty else {
//                    let reactor = EmptyTableViewCellReactor(type: .trendingRepo)
//                    return [.repo([TrendSectionItem.empty(reactor)])]
//                }
                return [.repo(self.repositories)]
            case .developers:
                guard !self.isRefreshing else {
                    return [.developer([])]
                }
//                guard !self.developers.isEmpty else {
//                    let reactor = EmptyTableViewCellReactor(type: .trendingDeveloper)
//                    return [.repo([TrendSectionItem.empty(reactor)])]
//                }
                return [.developer(self.developers)]
            }
        }
    }
	
    let initialState: TrendViewReactor.State
    
    fileprivate let crawlerService: GitTimeCrawlerServiceType
    fileprivate let userdefaultsService: UserDefaultsServiceType
    
	let headerViewReactor: TrendingHeaderViewReactor
	
    init(crawlerService: GitTimeCrawlerServiceType,
         userdefaultsService: UserDefaultsServiceType) {
        self.crawlerService = crawlerService
        self.userdefaultsService = userdefaultsService
        let period: PeriodTypes = PeriodTypes(rawValue: userdefaultsService.value(forKey: UserDefaultsKey.period) ?? "") ?? PeriodTypes.daily
        let language: Language? = userdefaultsService.structValue(forKey: UserDefaultsKey.langauge)
		
		headerViewReactor = TrendingHeaderViewReactor(period: period,
													  language: language)
		
        self.initialState = State(isLoading: false,
                                  isRefreshing: false,
                                  period: period,
                                  language: language,
                                  trendingType: .repositories,
                                  repositories: [],
                                  developers: [])
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            guard !self.currentState.isRefreshing else { return .empty() }
            let startRefreshing: Observable<Mutation> = .just(.setRefreshing(true))
            let endRefreshing: Observable<Mutation> = .just(.setRefreshing(false))
            let requestMutation = self.requestTrending()
            return .concat([startRefreshing, requestMutation, endRefreshing])
        case .selectPeriod(let period):
            GitTimeAnalytics.shared.logEvent(key: "select_period",
                                             parameters: ["period": period.periodText()])
            self.userdefaultsService.set(value: period.querySting(),
                                         forKey: UserDefaultsKey.period)
			self.headerViewReactor.action.onNext(.selectPeriod(period))
            let periodMutation: Observable<Mutation> = .just(.setPeriod(period))
            let requestMutation = self.requestTrending(period: period)
            return .concat([periodMutation, requestMutation])
        case .selectLanguage(let language):
            let languageName = language?.name ?? "All Language"
            GitTimeAnalytics.shared.logEvent(key: "select_language", parameters: ["language": languageName])
            self.userdefaultsService.setStruct(value: language, forKey: UserDefaultsKey.langauge)
			self.headerViewReactor.action.onNext(.selectLanguage(language))
            let languageMutation: Observable<Mutation> = .just(.setLanguage(language))
            let requestMutation = self.requestTrending(language: language)
            return .concat([languageMutation, requestMutation])
        case .switchSegmentControl:
            let trendType = self.currentState.trendingType == .repositories ? TrendTypes.developers : TrendTypes.repositories
            GitTimeAnalytics.shared.logEvent(key: "switch_trend",
                                             parameters: ["type": trendType.segmentTitle])
            let trendMutation: Observable<Mutation> = .just(.setTrendType(trendType))
            let requestMutation: Observable<Mutation> = self.requestTrending(trendType: trendType)
			
            return .concat([trendMutation, requestMutation])
        case .requestTrending:
            let requestMutation = self.requestTrending()
            return requestMutation
        }
        
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setLoading(isLoading):
            state.isLoading = isLoading
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
        case let .setPeriod(period):
            state.period = period
        case let .setLanguage(language):
            state.language = language
        case let .setTrendType(trendType):
            state.trendingType = trendType
        case let .fetchRepositories(repos):
            state.repositories = repos
                .map({ repo -> TrendingRepositoryCellReactor in
                    return TrendingRepositoryCellReactor.init(repo: repo, period: state.period)
                })
                .map(TrendSectionItem.trendingRepos)
        case let .fetchDevelopers(developers):
            state.developers = developers.map({ developer -> TrendingDeveloperCellReactor in
                return TrendingDeveloperCellReactor(developer: developer, rank: 0)
            })
                .map(TrendSectionItem.trendingDevelopers)
        }
        
        return state
    }
    
    fileprivate func requestTrending(trendType: TrendTypes? = nil,
                                     period: PeriodTypes? = nil,
                                     language: Language? = nil) -> Observable<Mutation> {
        let currentTrendType = trendType ?? self.currentState.trendingType
        let currentPeriod = period ?? self.currentState.period
        
        let currentLanguage = language ?? self.currentState.language
        let currentLanguageName = currentLanguage?.type == LanguageTypes.all ? "" : currentLanguage?.name
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        switch currentTrendType {
        case .repositories:
            /*
            let fetchRepositories: Observable<Mutation>
                = self.crawlerService.fetchTrendingRepositories(language: currentLanguageName,
                                                                period: currentPeriod.querySting())
                    .map { list -> Mutation in
                        return .fetchRepositories(list)
                }.catchErrorJustReturn(.fetchRepositories([]))
            */
            let fetchRepositoriesRawdata: Observable<Mutation> =
                self.crawlerService.fetchTrendingRepositoriesRawdata(language: currentLanguageName, period: currentPeriod.querySting())
                    .map { response -> Mutation in
                        let list = self.parseTredingRepositories(response: response)
                        return .fetchRepositories(list)
            }
            
            return .concat([startLoading, fetchRepositoriesRawdata, endLoading])
        case .developers:
            /*
            let fetchDevelopers: Observable<Mutation>
                = self.crawlerService.fetchTrendingDevelopers(language: currentLanguageName,
                                                              period: currentPeriod.querySting())
                    .map { developers -> Mutation in
                        return .fetchDevelopers(developers)
                }.catchErrorJustReturn(.fetchDevelopers([]))
            */
            let fetchDevelopersRawdata: Observable<Mutation> =
                self.crawlerService.fetchTredingDevelopersRawdata(language: currentLanguageName, period: currentPeriod.querySting())
                    .map { (response) -> Mutation in
                        let developers = self.parseTrendingDevelopers(response: response)
                        return .fetchDevelopers(developers)
            }
            
            return .concat([startLoading, fetchDevelopersRawdata, endLoading])
        }
    }
    
    private func parseTrendingDevelopers(response: Response) -> [TrendDeveloper] {
        
        var developers: [TrendDeveloper] = []
        
        if let doc = try? HTML(html: response.data, encoding: .utf8) {
            
            for item in  doc.xpath("//article[@class='Box-row d-flex']") {

                var trendDeveloperRepo = TrendDeveloperRepo(name: nil, url: "", description: "")
                var trendDeveloper = TrendDeveloper(userName: "", name: nil, url: "", profileURL: "", repo: trendDeveloperRepo)
                
                let name = item.xpath(".//div[@class='d-sm-flex flex-auto']/div[@class='col-sm-8 d-md-flex']/div[@class='col-md-6'][1]/h1")
                let username = item.xpath(".//div[@class='d-sm-flex flex-auto']/div[@class='col-sm-8 d-md-flex']/div[@class='col-md-6'][1]/p")
                let url = "https://github.com"
                let avatar = item.xpath(".//div[@class='mx-3']/a/img[@class='rounded-1 avatar-user']/@src")
                let repoName = item.xpath(".//h1[@class='h4 lh-condensed']")
                let repoURL = item.xpath(".//h1[@class='h4 lh-condensed']/a/@href")
                let repoDescription = item.xpath(".//div[@class='f6 text-gray mt-1']")
                let relativeURL = item.xpath(".//div[@class='d-sm-flex flex-auto']/div[@class='col-sm-8 d-md-flex']/div[@class='col-md-6'][1]/h1/a/@href")
                
                if let name = name.first?.text?.striped {
                    trendDeveloper.name = name
                }
                
                if let relativeURL = relativeURL.first?.text?.striped {
                    trendDeveloper.url = "\(url)\(relativeURL)"
                }
                
                if let userName = username.first?.text?.striped {
                    trendDeveloper.userName = userName
                    // trendDeveloper.url = "\(url)\(userName)"
                }
                
                if let profileURL = avatar.first?.text?.striped {
                    trendDeveloper.profileURL = profileURL
                }
                
                if let repoName = repoName.first?.text?.striped {
                    trendDeveloperRepo.name = repoName
                }
                
                if let repoURL = repoURL.first?.text?.striped {
                    trendDeveloperRepo.url = "\(url)\(repoURL)"
                }
                
                if let repoDescription = repoDescription.first?.text?.striped {
                    trendDeveloperRepo.description = repoDescription
                }
                
                trendDeveloper.repo = trendDeveloperRepo
                developers.append(trendDeveloper)
            }
            
        }
        
        return developers
    }
    
    private func parseTredingRepositories(response: Response) -> [TrendRepo] {
        
        var repositories: [TrendRepo] = []
        
        if let doc = try? HTML(html: response.data, encoding: .utf8) {
            
            for item in doc.xpath("//article[@class='Box-row']") {
                
				var trendRepo: TrendRepo = TrendRepo(author: "",
													 name: "",
													 url: "",
													 description: "",
													 language: "",
													 languageColor: "",
													 stars: 0,
													 forks: 0,
													 currentPeriodStars: 0,
													 contributors: [])
                
                /// Repository Info
                let repositoryInfo = item.xpath(".//h1[@class='h3 lh-condensed']/a")//[index]
                let description = item.xpath(".//p[@class='col-9 text-gray my-1 pr-4']")//[index]
                let languageColor = item.xpath(".//span[@class='d-inline-block ml-0 mr-3']/span[1]")
                let language = item.xpath(".//span[@class='d-inline-block ml-0 mr-3']/span[2]")
                let star = item.xpath(".//div[@class='f6 text-gray mt-2']/a[1]")//[index]
                let fork = item.xpath(".//div[@class='f6 text-gray mt-2']/a[2]")//[index]
                let todayStar = item.xpath(".//div[@class='f6 text-gray mt-2']/span[@class='d-inline-block float-sm-right']")//[index]
				// let contributors = item.xpath(".//div[@class='f6 text-gray mt-2']/span[@class='d-inline-block mr-3']")
				
                // repository Info
                if let repositoryInfo = repositoryInfo.first {
                    if let href = repositoryInfo["href"] {
                        trendRepo.url = "https://github.com\(href)"
                        
                        let userdata = href.split(separator: "/")
                        trendRepo.author = String(userdata[0])
                        trendRepo.name = String(userdata[1])
                    }
                }
                
                if let description = description.first {
                    if let desc = description.text {
                        trendRepo.description = desc.striped
                    }
                }
                
                if let color = languageColor.first {
                    guard let style = color["style"] else { return [] }
                    let bgCode = String(style.split(separator: ":")[1])
                    trendRepo.languageColor = bgCode.striped
                    
                } else {
                    trendRepo.languageColor = nil
                }
                
                if let language = language.first {
                    trendRepo.language = language.text?.striped
                } else {
                    trendRepo.language = nil
                }
                
                if var star = star.first?.text?.striped {
                    star = star.replacingOccurrences(of: ",", with: "")
                    trendRepo.stars = Int(star) ?? 0
                }
                
                if var fork = fork.first?.text?.striped {
                    fork = fork.replacingOccurrences(of: ",", with: "")
                    trendRepo.forks = Int(fork) ?? 0
                }
                
                if let today = todayStar.first?.text?.striped {
                    let result = today.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)
                    trendRepo.currentPeriodStars = Int(result) ?? 0
                }
                
				// Contributors
				/*
				/html/body[@class='logged-in env-production page-responsive']/div[@class='application-main ']/main/div[@class='explore-pjax-container container-lg p-responsive pt-6']/div[@class='Box']/div[2]/article[@class='Box-row'][1]/div[@class='f6 text-gray mt-2']/span[@class='d-inline-block mr-3']/a[@class='d-inline-block'][1]/img[@class='avatar mb-1 avatar-user']/@src
				*/
				for i in 1...5 {
					if let profile = item.xpath(".//div[@class='f6 text-gray mt-2']/span[@class='d-inline-block mr-3']/a[@class='d-inline-block'][\(i)]/img[@class='avatar mb-1 avatar-user']/@src").first?.text?.striped,
					   let name = item.xpath(".//div[@class='f6 text-gray mt-2']/span[@class='d-inline-block mr-3']/a[@class='d-inline-block'][\(i)]/@href").first?.text?.striped {
						let contributorModel = TrendRepoContributor(name: String(name.dropFirst()),
																	profileURL: profile)
						trendRepo.contributors.append(contributorModel)
					}
				}
				
				repositories.append(trendRepo)
            }
            
        }
        
        return repositories
    }
}
