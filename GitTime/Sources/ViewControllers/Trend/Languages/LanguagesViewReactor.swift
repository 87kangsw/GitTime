//
//  LanguagesViewReactor.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class LanguagesViewReactor: Reactor {
    
    enum Action {
        case firstLoad
        case selectCategory(LanguageTypes)
        case searchQuery(String?)
        case searchActive(Bool)
        case selectFavorite(Language)
        case toastMessage(String?)
    }
    
    enum Mutation {
        case setQuery(String?)
        case setSearchActive(Bool)
        case setCategory(LanguageTypes)
        case setLanguage([Language])
        case setFavoriteLanguaes([FavoriteLanguage])
        case addFavorite(FavoriteLanguage)
        case removeFavorite(Int)
        case setToastMessage(String?)
    }
    
    struct State {
        var query: String?
        var isSearchActive: Bool = false
        var languageType: LanguageTypes
        var selectedLanguage: Language?
        
        var allLanuage: [Language] {
            return  [Language.allLanguage]
        }
        var languages: [Language] = []
        
        var languageSections: [LanguageSection] {
            // All Language
            let allLanguageSectionItem = allLanuage.map({ language -> LanguageCellReactor in
                return LanguageCellReactor.init(language: language, isFavorite: false)
            }).map(LanguageSectionItem.allLanguage)
            
            // Lanugages
            let languagesSectionItem = self.languages
                .map({ language -> LanguageCellReactor in
                    let isFavorite = self.favoriteLanguages.contains(where: { $0.id == language.id})
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
    
    let initialState: LanguagesViewReactor.State
    
    fileprivate let languagesService: LanguagesServiceType
    fileprivate let userDefaultsService: UserDefaultsServiceType
    fileprivate let realmService: RealmServiceType
    
	let categoryViewReactor: LanguageCategoryViewReactor
	
    init(languagesService: LanguagesServiceType,
         userDefaultsService: UserDefaultsServiceType,
         realmService: RealmServiceType) {
        self.languagesService = languagesService
        self.userDefaultsService = userDefaultsService
        self.realmService = realmService
        
        let selectedLanguage: String = userDefaultsService.value(forKey: UserDefaultsKey.langauge) ?? ""
        let initType = LanguageTypes(rawValue: selectedLanguage) ?? .programming
        
		self.categoryViewReactor = LanguageCategoryViewReactor(languageCategoryType: initType)
		
        self.initialState = State(query: nil,
                                  isSearchActive: false,
                                  languageType: initType,
                                  selectedLanguage: nil,
                                  languages: [],
                                  favoriteLanguages: [])
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .firstLoad:
            let fetchFavorites: Observable<Mutation> = self.fetchFavoriteLanguages()
            return fetchFavorites
        case .searchActive(let active):
            GitTimeAnalytics.shared.logEvent(key: "search_active", parameters: nil)
            let activeMutation: Observable<Mutation> = .just(.setSearchActive(active))
            if active {
                let allDataMutation: Observable<Mutation> = self.searchMutation("")
                return .concat([activeMutation, allDataMutation])
            } else {
                let type = self.currentState.languageType
                let listMutation: Observable<Mutation> = self.categoryMutation(type)
                return .concat([activeMutation, listMutation])
            }
        case .selectCategory(let type):
            GitTimeAnalytics.shared.logEvent(key: "language_category",
                                             parameters: ["type": type.rawValue])
			categoryViewReactor.action.onNext(.selectCategory(type))

            let categoryMutation: Observable<Mutation> = .just(.setCategory(type))
            let listMutation: Observable<Mutation> = self.categoryMutation(type)
            let favoriteLanguagesMutation: Observable<Mutation> = self.fetchFavoriteLanguages()
            return .concat([categoryMutation, favoriteLanguagesMutation, listMutation])
        case .searchQuery(let query):
            guard let query = query else { return .empty() }
            guard self.currentState.isSearchActive else { return .empty() }
            GitTimeAnalytics.shared.logEvent(key: "search_query", parameters: ["query": query])
            let queryMutation: Observable<Mutation> = .just(.setQuery(query))
            let searchMutation: Observable<Mutation> = self.searchMutation(query)
            return .concat([queryMutation, searchMutation])
        case .selectFavorite(let language):
            let favoriteLanguages = self.currentState.favoriteLanguages
            
            if let favoriteItem = favoriteLanguages.enumerated().first(where: { $0.element.id == language.id }) {
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
        case let .setCategory(type):
            state.languageType = type
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
    
    private func categoryMutation(_ type: LanguageTypes) -> Observable<Mutation> {
        return self.languagesService.languageListByType(type)
            .map { list -> Mutation in
                return .setLanguage(list)
            }.catchErrorJustReturn(.setLanguage([]))
    }
    
    private func searchMutation(_ query: String) -> Observable<Mutation> {
        return self.languagesService.searchLanguage(searchText: query)
            .takeUntil(self.action.filter(isUpdateQueryAction))
            .map { result -> Mutation in
                return .setLanguage(result)
            }.catchErrorJustReturn(.setLanguage([]))
    }
    
    private func fetchFavoriteLanguages() -> Observable<Mutation> {
        self.realmService.loadFavoriteLanguages()
            .map { list -> Mutation in
                return .setFavoriteLanguaes(list)
        }.catchErrorJustReturn(.setFavoriteLanguaes([]))
    }

}
