//
//  FavoriteLanguageTableViewCellReactor.swift
//  GitTime
//
//  Created by Kanz on 2020/01/31.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class FavoriteLanguageTableViewCellReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var favoriteLanguage: FavoriteLanguage
    }
    
    let initialState: State
    
    init(favoriteLanguage: FavoriteLanguage) {
        initialState = State(favoriteLanguage: favoriteLanguage)
    }
}
