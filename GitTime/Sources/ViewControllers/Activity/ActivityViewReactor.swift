//
//  ActivityViewReactor.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class ActivityViewReactor: Reactor {
    
    static let INITIAL_PAGE = 1
    static let PER_PAGE = 30
    
    enum Action {
        case firstLoad
        case loadMoreActivities
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setContributionInfo(ContributionInfo)
        case fetchActivity([Event], nextPage: Int, canLoadMore: Bool)
        case fetchActivityMore([Event], nextPage: Int, canLoadMore: Bool)
        case setPage(Int)
        case setLoadMore(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var page: Int = 1
        var canLoadMore: Bool = true
        var contributionInfo: ContributionInfo?
        var contribution: [ActivitySectionItem]
        var activities: [ActivitySectionItem]
        var sectionItems: [ActivitySection] {
            return [
                .activities(self.activities)
            ]
        }
    }
    
    let initialState: ActivityViewReactor.State
    
    fileprivate let activityService: ActivityServiceType
    fileprivate let userService: UserServiceType
    fileprivate let crawlerService: GitTimeCrawlerServiceType
    
    init(activityService: ActivityServiceType,
         userService: UserServiceType,
         crawlerService: GitTimeCrawlerServiceType) {
        self.activityService = activityService
        self.userService = userService
        self.crawlerService = crawlerService
        self.initialState = State(isLoading: false,
                                  page: ActivityViewReactor.INITIAL_PAGE,
                                  canLoadMore: true,
                                  contributionInfo: nil,
                                  contribution: [],
                                  activities: [])
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .firstLoad:
            guard !self.currentState.isLoading else { return .empty() }
            let clearPagingMutation = self.clearPaging()
            let requestContributionMutation = self.requestContributions()
            let requestActivityMutation = self.requestActivities()
            return .concat([clearPagingMutation, requestContributionMutation, requestActivityMutation])
        case .loadMoreActivities:
            guard !self.currentState.isLoading else { return .empty() }
            guard self.currentState.canLoadMore else { return .empty() }
            let disableLoadMore: Observable<Mutation> = .just(.setLoadMore(false))
            let requestMoreActivityMuation: Observable<Mutation> = self.requestMoreActivities()
            return .concat([disableLoadMore, requestMoreActivityMuation])
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state 
        switch mutation {
        case let .setLoading(isLoading):
            state.isLoading = isLoading
        case let .setPage(page):
            state.page = page
        case let .setLoadMore(canLoadMore):
            state.canLoadMore = canLoadMore
        case let .setContributionInfo(contributionInfo):
            state.contributionInfo = contributionInfo
        case let .fetchActivity(activities, nextPage, canLoadMore):
            state.canLoadMore = canLoadMore
            state.page = nextPage
            state.activities = self.activitiesToSectionItem(activities.filter { $0.type != .none })
//            state.activities = self.activitiesToSectionItem(activities)
        case let .fetchActivityMore(activities, nextPage, canLoadMore):
            state.canLoadMore = canLoadMore
            state.page = nextPage
            let sectionItems = state.sectionItems[0].items
                + self.activitiesToSectionItem(activities.filter { $0.type != .none })
//                + self.activitiesToSectionItem(activities)
            state.activities = sectionItems
        }
        return state
    }
    
    private func clearPaging() -> Observable<Mutation> {
        return .concat([.just(.setPage(1)), .just(.setLoadMore(true))])
    }
    
    private func activitiesToSectionItem(_ activities: [Event]) -> [ActivitySectionItem] {
        guard !activities.isEmpty else {
            let reactor = EmptyTableViewCellReactor(type: .activity)
            return [ActivitySectionItem.empty(reactor)]
        }
        return activities
            .map { event -> ActivitySectionItem in
                let reactor = ActivityItemCellReactor(event: event)
                let eventType = event.type
                switch eventType {
                case .createEvent:
                    return ActivitySectionItem.createEvent(reactor)
                case .watchEvent:
                    return ActivitySectionItem.watchEvent(reactor)
                case .pullRequestEvent:
                    return ActivitySectionItem.pullRequestEvent(reactor)
                case .pushEvent:
                    return ActivitySectionItem.pushEvent(reactor)
                case .forkEvent:
                    return ActivitySectionItem.forkEvent(reactor)
                case .issuesEvent:
                    return ActivitySectionItem.issuesEvent(reactor)
                case .issueCommentEvent:
                    return ActivitySectionItem.issueCommentEvent(reactor)
                case .releaseEvent:
                    return ActivitySectionItem.releaseEvent(reactor)
                case .pullRequestReviewCommentEvent:
                    return ActivitySectionItem.pullRequestReviewCommentEvent(reactor)
                case .publicEvent:
                    return ActivitySectionItem.publicEvent(reactor)
                case .none:
                    return ActivitySectionItem.createEvent(reactor)
                }
        }
    }
    
    private func requestContributions() -> Observable<Mutation> {
        
        guard let me = self.userService.me else { return .empty() }
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        let fetchContribution = self.crawlerService.fetchContributions(userName: me.name)
            .map { contributionInfo -> Mutation in
                return .setContributionInfo(contributionInfo)
            }
        return .concat([startLoading, fetchContribution, endLoading])
    }
    
    private func requestActivities(page: Int? = 1) -> Observable<Mutation> {
        
        guard let me = self.userService.me else { return .empty() }
        
        let currentPage = page ?? self.currentState.page
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        // log.info("\(#function) \(currentPage)")
        
        let fetchActivity = self.activityService.fetchActivities(userName: me.name, page: currentPage)
            .map { events -> Mutation in
                let newPage = events.count < ActivityViewReactor.PER_PAGE ? currentPage : currentPage + 1
                let canLoadMore = events.count == ActivityViewReactor.PER_PAGE
                return .fetchActivity(events, nextPage: newPage, canLoadMore: canLoadMore)
            }.catchErrorJustReturn(.fetchActivity([], nextPage: currentPage, canLoadMore: false))
        
        return .concat([startLoading, fetchActivity, endLoading])
    }
    
    private func requestMoreActivities(page: Int? = 1) -> Observable<Mutation> {
        
        guard let me = self.userService.me else { return .empty() }
        
        let currentPage = self.currentState.page
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        log.info("\(#function) \(currentPage)")
        
        let fetchActivity = self.activityService.fetchActivities(userName: me.name, page: currentPage)
            .map { events -> Mutation in
                let newPage = events.count < ActivityViewReactor.PER_PAGE ? currentPage : currentPage + 1
                let canLoadMore = events.count == ActivityViewReactor.PER_PAGE
                return .fetchActivityMore(events, nextPage: newPage, canLoadMore: canLoadMore)
            }.catchErrorJustReturn(.fetchActivityMore([], nextPage: currentPage, canLoadMore: false))
        
        return .concat([startLoading, fetchActivity, endLoading])
    }
    
}
