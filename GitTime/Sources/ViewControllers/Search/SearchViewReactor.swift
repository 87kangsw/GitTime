//
//  SearchViewReactor.swift
//  GitTime
//
//  Created by Kanz on 09/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

class SearchViewReactor: Reactor {
    
    static let INITIAL_PAGE = 1
    static let PER_PAGE = 30
    
    enum Action {
        case selectType(SearchTypes)
        case searchQuery(String?)
        case loadMore
        case showRecentSearchWords(Bool)
        case removeRecentSearchWord(IndexPath, String)
        case selectLanguage(GithubLanguage?)
    }
    
    enum Mutation {
        case setType(SearchTypes)
        case setQuery(String)
        case setLoading(Bool)
        case setSearchUsers([User], nextPage: Int, canLoadMore: Bool)
        case setMoreSearchUsers([User], nextPage: Int, canLoadMore: Bool)
        case setSearchRepos([Repository], nextPage: Int, canLoadMore: Bool)
        case setMoreSearchRepos([Repository], nextPage: Int, canLoadMore: Bool)
        case setRecentSearchedWords([SearchHistory])
        case setPage(Int)
        case setLoadMore(Bool)
        case setShowRecentSearchWords(Bool)
        case removeRecentSearchWord(IndexPath)
        case setLanguage(GithubLanguage?)
    }
    
    struct State {
        var query: String?
        var segmentType: SearchTypes
        var isLoading: Bool
        var searchedUsers: [SearchResultsSectionItem]
        var searchedRepos: [SearchResultsSectionItem]
        var recentSearchedWords: [SearchResultsSectionItem]
        var sections: [SearchResultsSection] {
            
            if self.isShowRecentSearchWords {
                return [.recentSearchWords(self.recentSearchedWords)]
            }
            
            switch self.segmentType {
            case .users:
                return [.searchUsers(self.searchedUsers)]
                
            case .repositories:
                return [.seachRepositories(self.searchedRepos)]
            }
        }
        var page: Int = 1
        var canLoadMore: Bool = true
        var isShowRecentSearchWords: Bool = false
        var language: GithubLanguage?
    }
    
    fileprivate let searchService: SearchServiceType
    fileprivate let languageService: LanguagesServiceType
    fileprivate let realmService: RealmServiceType
    fileprivate let userdefaultsService: UserDefaultsServiceType
    let initialState: State
    
    init(searchService: SearchServiceType,
         languageService: LanguagesServiceType,
         realmService: RealmServiceType,
         userdefaultsService: UserDefaultsServiceType) {
        self.searchService = searchService
        self.languageService = languageService
        self.realmService = realmService
        self.userdefaultsService = userdefaultsService
        
        let language: GithubLanguage? = userdefaultsService.structValue(forKey: UserDefaultsKey.langauge)
		
        self.initialState = State(query: nil,
                             segmentType: .users,
                             isLoading: false,
                             searchedUsers: [],
                             searchedRepos: [],
                             recentSearchedWords: [],
                             page: SearchViewReactor.INITIAL_PAGE,
                             canLoadMore: false,
                             isShowRecentSearchWords: false,
                             language: language)
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .searchQuery(let query):
            guard let query = query, !query.isEmpty else { return .concat([self.clearPaging(), self.clearResults()]) }
            let queryMutation: Observable<Mutation> = .just(.setQuery(query))
            let startLoadingMutation: Observable<Mutation> = .just(.setLoading(true))
            let endLoadingMutation: Observable<Mutation> = .just(.setLoading(false))
            let requestMutation: Observable<Mutation> = (self.currentState.segmentType == SearchTypes.users) ?
                self.searchUsersMutation(query: query) : self.searchRepositoriesMutation(query: query)
            let showRecentWordsMutation: Observable<Mutation> = .just(.setShowRecentSearchWords(false))
            // Words store in realm..
            self.storeSearchWord(query)
            GitTimeAnalytics.shared.logEvent(key: "search_query",
                                             parameters: ["query": query])
            return .concat([showRecentWordsMutation, startLoadingMutation, queryMutation, requestMutation, endLoadingMutation])
        case .selectType(let type):
            let clearPagingMutation = self.clearPaging()
            let clearResults = self.clearResults()
            let searchTypeMutation: Observable<Mutation> = .just(.setType(type))
            GitTimeAnalytics.shared.logEvent(key: "switch_search",
                                             parameters: ["type": type.segmentTitle.lowercased()])
            return .concat([clearPagingMutation, clearResults, searchTypeMutation])
        case .loadMore:
            guard !self.currentState.isLoading else { return .empty() }
            guard self.currentState.canLoadMore else { return .empty() }
            let disableLoadMore: Observable<Mutation> = .just(.setLoadMore(false))
            let startLoadingMutation: Observable<Mutation> = .just(.setLoading(true))
            let endLoadingMutation: Observable<Mutation> = .just(.setLoading(false))
            let requestMoreMuation: Observable<Mutation> = self.requestSearchMore()
            return .concat([disableLoadMore, startLoadingMutation, requestMoreMuation, endLoadingMutation])
        case .showRecentSearchWords(let isShow):
            let showRecentWordsMutation: Observable<Mutation> = .just(.setShowRecentSearchWords(isShow))
            let fetchRecentWordsMutation: Observable<Mutation> = self.fetchRecentSearchWordsMutation()
            return .concat(showRecentWordsMutation, fetchRecentWordsMutation)
        case .removeRecentSearchWord(let indexPath, let text):
            // Word remove from realm..
            self.removeSearchWord(text)
            GitTimeAnalytics.shared.logEvent(key: "remove_recent_word", parameters: nil)
            return .just(.removeRecentSearchWord(indexPath))
        case .selectLanguage(let language):
            guard self.currentState.segmentType == SearchTypes.repositories else { return .empty() }
            self.userdefaultsService.setStruct(value: language, forKey: UserDefaultsKey.langauge)
            let languageMutation: Observable<Mutation> = .just(.setLanguage(language))
            let languageName = language?.name ?? "All Language"
            GitTimeAnalytics.shared.logEvent(key: "select_language",
                                             parameters: ["language": languageName])
            guard let query = self.currentState.query, !query.isEmpty else { return .empty() }
            let startLoadingMutation: Observable<Mutation> = .just(.setLoading(true))
            let endLoadingMutation: Observable<Mutation> = .just(.setLoading(false))
            let requestMutation: Observable<Mutation> = self.searchRepositoriesMutation(query: query, language: language)
            
            return .concat([languageMutation, startLoadingMutation, requestMutation, endLoadingMutation])
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setQuery(let query):
            state.query = query
        case .setType(let type):
            state.segmentType = type
        case .setSearchUsers(let users, let nextPage, let canLoadMore):
            state.page = nextPage
            state.canLoadMore = canLoadMore
            state.searchedUsers = users.map { user -> SearchUserCellReactor in
                return SearchUserCellReactor(user: user)
                }.map(SearchResultsSectionItem.searchedUser)
        case .setMoreSearchUsers(let users, let nextPage, let canLoadMore):
            state.page = nextPage
            state.canLoadMore = canLoadMore
            state.searchedUsers =
                state.searchedUsers + users.map { user -> SearchUserCellReactor in
                    return SearchUserCellReactor(user: user)
                    }.map(SearchResultsSectionItem.searchedUser)
        case .setSearchRepos(let repos, let nextPage, let canLoadMore):
            state.page = nextPage
            state.canLoadMore = canLoadMore
            state.searchedRepos = repos.map { repo -> SearchRepoCellReactor in
                return SearchRepoCellReactor(repo: repo)
                }.map(SearchResultsSectionItem.searchedRepository)
        case .setMoreSearchRepos(let repos, let nextPage, let canLoadMore):
            state.page = nextPage
            state.canLoadMore = canLoadMore
            state.searchedRepos =
                state.searchedRepos + repos.map { repo -> SearchRepoCellReactor in
                    return SearchRepoCellReactor(repo: repo)
                    }.map(SearchResultsSectionItem.searchedRepository)
        case let .setPage(page):
            state.page = page
        case let .setLoadMore(canLoadMore):
            state.canLoadMore = canLoadMore
        case let .setShowRecentSearchWords(isShowRecentSearchWords):
            state.isShowRecentSearchWords = isShowRecentSearchWords
        case let .setRecentSearchedWords(recentWords):
            state.recentSearchedWords = recentWords.map { word -> SearchHistoryCellReactor in
                return SearchHistoryCellReactor(history: word)
            }.map(SearchResultsSectionItem.recentWord)
        case let .removeRecentSearchWord(indexPath):
            state.recentSearchedWords.remove(at: indexPath.row)
        case let .setLanguage(language):
            state.language = language
        }
        return state
    }
    
    // MARK: - Search User / Repository
    
    private func searchUsersMutation(query: String) -> Observable<Mutation> {
        let currentPage = SearchViewReactor.INITIAL_PAGE
        guard !query.isEmpty else { return .just(.setSearchUsers([], nextPage: currentPage, canLoadMore: false)) }
        return self.searchService.searchUser(query: query, page: currentPage)
            .map { (lists, canLoadMore) -> Mutation in
                let newPage = !canLoadMore ? currentPage : currentPage + 1
                return .setSearchUsers(lists, nextPage: newPage, canLoadMore: canLoadMore)
            }.catchAndReturn(.setSearchUsers([], nextPage: currentPage, canLoadMore: false))
    }

    private func searchRepositoriesMutation(query: String, language: GithubLanguage? = nil) -> Observable<Mutation> {
        let currentPage = SearchViewReactor.INITIAL_PAGE
        guard !query.isEmpty else { return .just(.setSearchRepos([], nextPage: currentPage, canLoadMore: false)) }
        let language = language ?? self.currentState.language
        return self.searchService.searchRepo(query: query, page: currentPage, language: language?.name)
            .map { (lists, canLoadMore) -> Mutation in
                let newPage = !canLoadMore ? currentPage : currentPage + 1
                return .setSearchRepos(lists, nextPage: newPage, canLoadMore: canLoadMore)
        }.catchAndReturn(.setSearchRepos([], nextPage: currentPage, canLoadMore: false))
    }
    
    private func clearPaging() -> Observable<Mutation> {
        return .concat([.just(.setPage(1)), .just(.setLoadMore(true))])
    }
    
    private func clearResults() -> Observable<Mutation> {
        let userClear: Observable<Mutation> = .just(.setSearchUsers([], nextPage: 1, canLoadMore: false))
        let repoClear: Observable<Mutation> = .just(.setSearchRepos([], nextPage: 1, canLoadMore: false))
        return .concat([userClear, repoClear])
    }
    
    private func requestSearchMore() -> Observable<Mutation> {
        guard let query = self.currentState.query else { return .empty() }
        let currentSearchType = self.currentState.segmentType
        let currentPage = self.currentState.page
        let language = self.currentState.language
        
        switch currentSearchType {
        case .users:
            return self.searchService.searchUser(query: query, page: currentPage)
                .map { (lists, canLoadMore) -> Mutation in
                    let newPage = !canLoadMore ? currentPage : currentPage + 1
                    return .setMoreSearchUsers(lists, nextPage: newPage, canLoadMore: canLoadMore)
                }.catchAndReturn(.setMoreSearchUsers([], nextPage: currentPage, canLoadMore: false))
        case .repositories:
            return self.searchService.searchRepo(query: query, page: currentPage, language: language?.name)
                .map { (lists, canLoadMore) -> Mutation in
                    let newPage = !canLoadMore ? currentPage : currentPage + 1
                    return .setMoreSearchRepos(lists, nextPage: newPage, canLoadMore: canLoadMore)
                }.catchAndReturn(.setMoreSearchRepos([], nextPage: currentPage, canLoadMore: false))
        }
    }
    
    // MARK: - Recent Search Word
    
    private func fetchRecentSearchWordsMutation() -> Observable<Mutation> {
        return self.realmService.recentSearchTextList()
            .map { list -> Mutation in
                return .setRecentSearchedWords(list)
        }
    }
    
    private func storeSearchWord(_ text: String) {
        self.realmService.addSearchText(text: text)
    }
    
    private func removeSearchWord(_ text: String) {
        self.realmService.removeSearchText(text: text)
    }
}
