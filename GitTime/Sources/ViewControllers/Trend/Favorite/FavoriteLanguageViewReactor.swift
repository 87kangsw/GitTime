//
//  FavoriteLanguageViewReactor.swift
//  GitTime
//
//  Created by Kanz on 2020/01/18.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class FavoriteLanguageViewReactor: Reactor {
    
    enum Action {
        case firstLoad
        case removeFavorite(FavoriteLanguage)
        case toastMessage(String?)
    }
    
    enum Mutation {
        case setFavoriteLanguaes([FavoriteLanguage])
        case removeFavorite(Int)
        case setToastMessage(String?)
    }
    
    struct State {
        var favoriteLanguages: [FavoriteLanguage]
        var sections: [FavoriteLanguageSection] {
            let sectionItems = favoriteLanguages.map { FavoriteLanguageCellReactor(favoriteLanguage: $0) }
                .map(FavoriteLanguageSectionItem.favorite)
            return [.favorite(sectionItems)]
        }
        var toastMessage: String?
    }
    
    fileprivate let realmService: RealmServiceType
    
    let initialState: State
    
    init(realmService: RealmServiceType) {
        self.realmService = realmService
        
        initialState = State(favoriteLanguages: [])
    }
    
    // MARK: Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .firstLoad:
            return self.fetchFavoriteLanguages()
            
        case .removeFavorite(let favoriteLanguage):
            GitTimeAnalytics.shared.logEvent(key: "remove_favorite",
                                             parameters: ["language": favoriteLanguage.name])
            let favoriteLanguages = self.currentState.favoriteLanguages
            guard let favoriteItem = favoriteLanguages.enumerated().first(where: { $0.element.name == favoriteLanguage.name }) else {
                return .empty()
            }
            
            self.realmService.removeFavoriteLanguage(favoriteItem.element)
            let removeFavorite: Observable<Mutation> = Observable.just(.removeFavorite(favoriteItem.offset))
            let toastMessage: Observable<Mutation> = Observable.just(.setToastMessage("Removed from your favorites."))
            return .concat(removeFavorite, toastMessage)
            
        case .toastMessage(let message):
            return Observable.just(.setToastMessage(message))
        }
    }
    
    // MARK: Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setFavoriteLanguaes(let languages):
            state.favoriteLanguages = languages
        case .removeFavorite(let index):
            var favoriteLanguages = state.favoriteLanguages
            favoriteLanguages.remove(at: index)
            state.favoriteLanguages = favoriteLanguages
        case .setToastMessage(let message):
            state.toastMessage = message
        }
        return state
    }
    
    private func fetchFavoriteLanguages() -> Observable<Mutation> {
        self.realmService.loadFavoriteLanguages()
            .map { list -> Mutation in
                return .setFavoriteLanguaes(list)
        }.catchAndReturn(.setFavoriteLanguaes([]))
    }
}
