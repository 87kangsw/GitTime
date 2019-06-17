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
        case selectCategory(LanguageTypes)
        case searchQuery(String?)
        case searchActive(Bool)
    }
    
    enum Mutation {
        case setQuery(String?)
        case setSearchActive(Bool)
        case setCategory(LanguageTypes)
        case setLanguage([Language])
    }
    
    struct State {
        var query: String?
        var isSearchActive: Bool = false
        var languageType: LanguageTypes
        var selectedLanguage: Language?
        var allLanuage: [LanguageSectionItem] {
            let languages = [Language.allLanguage]
            return languages
                .map ({ language -> LanguageListCellReactor in
                    return LanguageListCellReactor.init(language: language)
                })
                .map(LanguageSectionItem.allLanguage)
        }
        var languages: [LanguageSectionItem] = []
        var languageSections: [LanguageSection] {
            if !isSearchActive {
                return [
                    .allLanguage(self.allLanuage),
                    .languages(self.languages)
                ]
            }
            return [.languages(self.languages)]
        }
    }
    
    let initialState: LanguagesViewReactor.State
    
    fileprivate let languagesService: LanguagesServiceType
    fileprivate let userDefaultsService: UserDefaultsServiceType
    
    init(languagesService: LanguagesServiceType,
         userDefaultsService: UserDefaultsServiceType) {
        self.languagesService = languagesService
        self.userDefaultsService = userDefaultsService
        
        let selectedLanguage: String = userDefaultsService.value(forKey: UserDefaultsKey.langauge) ?? ""
        let initType = LanguageTypes(rawValue: selectedLanguage) ?? .programming
        
        self.initialState = State(query: nil,
                                  isSearchActive: false,
                                  languageType: initType,
                                  selectedLanguage: nil,
                                  languages: [])
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .searchActive(let active):
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
            let categoryMutation: Observable<Mutation> = .just(.setCategory(type))
            let listMutation: Observable<Mutation> = self.categoryMutation(type)
            return .concat([categoryMutation, listMutation])
        case .searchQuery(let query):
            guard let query = query else { return .empty() }
            guard self.currentState.isSearchActive else { return .empty() }
            
            let queryMutation: Observable<Mutation> = .just(.setQuery(query))
            let searchMutation: Observable<Mutation> = self.searchMutation(query)
            return .concat([queryMutation, searchMutation])
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
                .map ({ language -> LanguageListCellReactor in
                    return LanguageListCellReactor.init(language: language)
                })
                .map(LanguageSectionItem.languages)
        case let .setQuery(query):
            state.query = query
        case let .setSearchActive(active):
            state.isSearchActive = active
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
    
    private func allLanguageCellReactor() -> [LanguageSectionItem] {
        let languages = [Language.allLanguage]
        return languages
            .map ({ language -> LanguageListCellReactor in
                return LanguageListCellReactor.init(language: language)
            })
            .map(LanguageSectionItem.languages)
    }
}
