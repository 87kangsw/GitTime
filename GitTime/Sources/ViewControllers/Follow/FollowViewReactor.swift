//
//  FollowViewReactor.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class FollowViewReactor: Reactor {
    
    static let INITIAL_PAGE = 1
    static let PER_PAGE = 10
    
    enum Action {
        case refresh
        case switchSegmentControl
        case loadMore
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setFollowType(FollowTypes)
        case fetchFollow([User], nextPage: Int, canLoadMore: Bool)
        case fetchMoreFollow([User], nextPage: Int, canLoadMore: Bool)
        case setPage(Int)
        case setLoadMore(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var followType: FollowTypes
        var followUsers: [FollowSectionItem]
        var followSections: [FollowSection] {
            return [.followUsers(self.followUsers)]
        }
        var page: Int = 1
        var canLoadMore: Bool = true
    }
    
    let initialState: FollowViewReactor.State
    
    fileprivate let followService: FollowServiceType
    fileprivate let userService: UserServiceType
    
    init(followService: FollowServiceType,
         userService: UserServiceType) {
        self.followService = followService
        self.userService = userService
        self.initialState = State(isLoading: false,
                                  isRefreshing: false,
                                  followType: .followers,
                                  followUsers: [],
                                  page: FollowViewReactor.INITIAL_PAGE,
                                  canLoadMore: true)
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            guard !self.currentState.isRefreshing else { return .empty() }
            guard !self.currentState.isLoading else { return .empty() }
            let startRefreshing: Observable<Mutation> = .just(.setRefreshing(true))
            let endRefreshing: Observable<Mutation> = .just(.setRefreshing(false))
            let clearPagingMutation = self.clearPaging()
            let requestMutation = self.requestFollow()
            return .concat([clearPagingMutation, startRefreshing, endRefreshing, requestMutation])
        case .switchSegmentControl:
            let followType = self.currentState.followType == .followers ? FollowTypes.following : FollowTypes.followers
            GitTimeAnalytics.shared.logEvent(key: "switch_follow",
                                             parameters: ["type": followType.segmentTitle])
            let clearPagingMutation = self.clearPaging()
            let followMutation: Observable<Mutation> = .just(.setFollowType(followType))
            let requestMutation: Observable<Mutation> = self.requestFollow(followType: followType)
            return .concat([clearPagingMutation, followMutation, requestMutation])
        case .loadMore:
            guard !self.currentState.isRefreshing else { return .empty() }
            guard !self.currentState.isLoading else { return .empty() }
            guard self.currentState.canLoadMore else { return .empty() }
            let disableLoadMore: Observable<Mutation> = .just(.setLoadMore(false))
            let requestMoreMuation: Observable<Mutation> = self.requestFollowMore()
            return .concat([disableLoadMore, requestMoreMuation])
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
        case let .setFollowType(followType):
            state.followType = followType
        case let .setPage(page):
            state.page = page
        case let .setLoadMore(canLoadMore):
            state.canLoadMore = canLoadMore
        case let .fetchFollow(followUsers, nextPage, canLoadMore):
            state.canLoadMore = canLoadMore
            state.page = nextPage
            state.followUsers = followUsers
                .map { user -> FollowUserCellReactor in
                    return FollowUserCellReactor(user: user)
                }
                .map(FollowSectionItem.followUsers)
        case let .fetchMoreFollow(followUsers, nextPage, canLoadMore):
            state.canLoadMore = canLoadMore
            state.page = nextPage
            let sectionItems = state.followSections[0].items
                + followUsers.map { user -> FollowUserCellReactor in
                    return FollowUserCellReactor(user: user)
                }.map(FollowSectionItem.followUsers)
            state.followUsers = sectionItems
        }
        
        return state
    }
    
    private func clearPaging() -> Observable<Mutation> {
        return .concat([.just(.setPage(1)), .just(.setLoadMore(true))])
    }
    
    private func requestFollow(followType: FollowTypes? = nil, page: Int? = 1) -> Observable<Mutation> {
        
//        if AppDependency.shared.isTrial {
//            return self.trialFollows()
//        }
        
        guard let me = self.userService.me else { return .empty() }
        
        let currentFollowType = followType ?? self.currentState.followType
        let currentPage = page ?? self.currentState.page
        
        log.info("\(#function) \(currentFollowType)")
        log.info("\(#function) \(currentPage)")
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        switch currentFollowType {
        case .followers:
            let fetchFollowers: Observable<Mutation> = self.followService.fetchFollowers(userName: me.name,
                                                                                         page: currentPage)
                .map { users -> Mutation in
                    let newPage = users.count < FollowViewReactor.PER_PAGE ? currentPage : currentPage + 1
                    let canLoadMore = users.count == FollowViewReactor.PER_PAGE
                    return .fetchFollow(users, nextPage: newPage, canLoadMore: canLoadMore)
                }.catchErrorJustReturn(.fetchFollow([], nextPage: currentPage, canLoadMore: false))
            return .concat([startLoading, fetchFollowers, endLoading])
            
        case .following:
            let fetchFollowing: Observable<Mutation> = self.followService.fetchFollowing(userName: me.name,
                                                                                         page: currentPage)
                .map { users -> Mutation in
                    let newPage = users.count < FollowViewReactor.PER_PAGE ? currentPage : currentPage + 1
                    let canLoadMore = users.count == FollowViewReactor.PER_PAGE
                    return .fetchFollow(users, nextPage: newPage, canLoadMore: canLoadMore)
                }.catchErrorJustReturn(.fetchFollow([], nextPage: currentPage, canLoadMore: false))
            return .concat([startLoading, fetchFollowing, endLoading])
        }
    }
    
    private func requestFollowMore(page: Int? = 1) -> Observable<Mutation> {
        
        guard let me = self.userService.me else { return .empty() }
        
        let currentFollowType = self.currentState.followType
        let currentPage = self.currentState.page
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        log.info("\(#function) \(currentFollowType)")
        log.info("\(#function) \(currentPage)")

        switch currentFollowType {
        case .followers:
            let fetchFollowers: Observable<Mutation> = self.followService.fetchFollowers(userName: me.name,
                                                                                         page: currentPage)
                .map { users -> Mutation in
                    let newPage = users.count < FollowViewReactor.PER_PAGE ? currentPage : currentPage + 1
                    let canLoadMore = users.count == FollowViewReactor.PER_PAGE
                    return .fetchMoreFollow(users, nextPage: newPage, canLoadMore: canLoadMore)
                }.catchErrorJustReturn(.fetchFollow([], nextPage: currentPage, canLoadMore: false))
            return .concat([startLoading, fetchFollowers, endLoading])
            
        case .following:
            let fetchFollowing: Observable<Mutation> = self.followService.fetchFollowing(userName: me.name,
                                                                                         page: currentPage)
                .map { users -> Mutation in
                    let newPage = users.count < FollowViewReactor.PER_PAGE ? currentPage : currentPage + 1
                    let canLoadMore = users.count == FollowViewReactor.PER_PAGE
                    return .fetchMoreFollow(users, nextPage: newPage, canLoadMore: canLoadMore)
                }.catchErrorJustReturn(.fetchFollow([], nextPage: currentPage, canLoadMore: false))
            return .concat([startLoading, fetchFollowing, endLoading])
        }
    }
    
    private func trialFollows() -> Observable<Mutation> {
        return self.followService.trialFollow()
            .map { users -> Mutation in
                return .fetchFollow(users, nextPage: 1, canLoadMore: false)
        }
        
    }
}
