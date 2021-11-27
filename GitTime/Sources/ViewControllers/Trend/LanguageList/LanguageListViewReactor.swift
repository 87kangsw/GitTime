//
//  LanguageListViewReactor.swift
//  GitTime
//
//  Created Kanz on 2021/09/16.
//  Copyright © 2021 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class LanguageListViewReactor: Reactor {
    
    enum Action {
		case firstLoad
		case searchQuery(String?)
		case searchActive(Bool)
		case selectFavorite(GithubLanguage)
		case toastMessage(String?)
    }
    
    enum Mutation {
		case setQuery(String?)
		case setSearchActive(Bool)
		case setLanguage([GithubLanguage])
		case setFavoriteLanguaes([FavoriteLanguage])
		case addFavorite(FavoriteLanguage)
		case removeFavorite(Int)
		case setToastMessage(String?)
    }
    
    struct State {
		var query: String?
		var isSearchActive: Bool = false
		
		var allLanuage: [GithubLanguage] {
			return  [GithubLanguage.allLanguage]
		}
		var languages: [GithubLanguage] = []
		
		var languageSections: [LanguageSection] {
			// All Language
			let allLanguageSectionItem = allLanuage.map({ language -> LanguageCellReactor in
				return LanguageCellReactor.init(language: language, isFavorite: false)
			}).map(LanguageSectionItem.allLanguage)
			
			// Lanugages
			let languagesSectionItem = self.languages
				.map({ language -> LanguageCellReactor in
					let isFavorite = self.favoriteLanguages.contains(where: { $0.name == language.name })
					return LanguageCellReactor.init(language: language, isFavorite: isFavorite)
				}).map(LanguageSectionItem.languages)
			
			if !isSearchActive {
				return [
					.allLanguage(allLanguageSectionItem),
					.languages(languagesSectionItem)
				]
			}
			return [.languages(languagesSectionItem)]
		}
		var favoriteLanguages: [FavoriteLanguage]
		var toastMessage: String?
    }
    
    let initialState: State
    
	private let languagesService: LanguagesServiceType
	private let userDefaultsService: UserDefaultsServiceType
	private let realmService: RealmServiceType
	
	// MARK: Initializing
	init(
		languagesService: LanguagesServiceType,
		userDefaultsService: UserDefaultsServiceType,
		realmService: RealmServiceType
	) {
		self.languagesService = languagesService
		self.userDefaultsService = userDefaultsService
		self.realmService = realmService
		
		self.initialState = State(query: nil,
								  isSearchActive: false,
								  languages: [],
								  favoriteLanguages: [])
    }
    
    // MARK: Mutate
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
		case .firstLoad:
			let fetchFavorites: Observable<Mutation> = self.fetchFavoriteLanguages()
			let listMutation: Observable<Mutation> = self.languageList()
			return .concat([fetchFavorites, listMutation])
		case .searchActive(let active):
			GitTimeAnalytics.shared.logEvent(key: "search_active", parameters: nil)
			let activeMutation: Observable<Mutation> = .just(.setSearchActive(active))
			if active {
				let allDataMutation: Observable<Mutation> = self.searchMutation("")
				return .concat([activeMutation, allDataMutation])
			} else {
				return activeMutation
			}
		case .searchQuery(let query):
			guard let query = query else { return .empty() }
			guard self.currentState.isSearchActive else { return .empty() }
			GitTimeAnalytics.shared.logEvent(key: "search_query", parameters: ["query": query])
			let queryMutation: Observable<Mutation> = .just(.setQuery(query))
			let searchMutation: Observable<Mutation> = self.searchMutation(query)
			return .concat([queryMutation, searchMutation])
		case .selectFavorite(let language):
			let favoriteLanguages = self.currentState.favoriteLanguages
			
			if let favoriteItem = favoriteLanguages.enumerated().first(where: { $0.element.name == language.name }) {
				self.realmService.removeFavoriteLanguage(favoriteItem.element)
				let removeFavorite: Observable<Mutation> = Observable.just(.removeFavorite(favoriteItem.offset))
				let toastMessage: Observable<Mutation> = Observable.just(.setToastMessage("Removed from your favorites."))
				GitTimeAnalytics.shared.logEvent(key: "remove_favorite", parameters: ["language": language.name])
				return .concat(removeFavorite, toastMessage)
			} else {
				let favoriteItem = language.toFavoriteLanguage()
				self.realmService.addFavoriteLanguage(language)
				let addFavorite: Observable<Mutation> = Observable.just(.addFavorite(favoriteItem))
				let toastMessage: Observable<Mutation> = Observable.just(.setToastMessage("Added to favorites."))
				GitTimeAnalytics.shared.logEvent(key: "add_favorite", parameters: ["language": language.name])
				return .concat(addFavorite, toastMessage)
			}
		case .toastMessage(let message):
			return Observable.just(.setToastMessage(message))
        }
    }
    
    // MARK: Reduce
    
    func reduce(state: State, mutation: Mutation) -> State {
		var state = state
		switch mutation {
		case let .setLanguage(languages):
			state.languages = languages
		case let .setQuery(query):
			state.query = query
		case let .setSearchActive(active):
			state.isSearchActive = active
		case let .setFavoriteLanguaes(languages):
			state.favoriteLanguages = languages
		case .addFavorite(let language):
			var favoriteLanguages = state.favoriteLanguages
			favoriteLanguages.append(language)
			state.favoriteLanguages = favoriteLanguages
		case .removeFavorite(let index):
			var favoriteLanguages = state.favoriteLanguages
			favoriteLanguages.remove(at: index)
			state.favoriteLanguages = favoriteLanguages
		case .setToastMessage(let message):
			state.toastMessage = message
		}
		return state
    }
	
	private func isUpdateQueryAction(_ action: Action) -> Bool {
		if case .searchQuery = action {
			return true
		} else {
			return false
		}
	}
	
	private func searchMutation(_ query: String) -> Observable<Mutation> {
		return self.languagesService.searchLanguage(searchText: query)
			.take(until: self.action.filter(isUpdateQueryAction))
			.map { result -> Mutation in
				return .setLanguage(result)
			}.catchAndReturn(.setLanguage([]))
	}
	
	private func fetchFavoriteLanguages() -> Observable<Mutation> {
		self.realmService.loadFavoriteLanguages()
			.map { list -> Mutation in
				return .setFavoriteLanguaes(list)
		}.catchAndReturn(.setFavoriteLanguaes([]))
	}
	
	private func languageList() -> Observable<Mutation> {
		return self.languagesService.getLanguageList()
			.map { list -> Mutation in
				return .setLanguage(list)
			}.catchAndReturn(.setLanguage([]))
	}
}
