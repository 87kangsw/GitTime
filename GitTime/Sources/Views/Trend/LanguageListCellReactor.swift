//
//  LanguageListCellReactor.swift
//  GitTime
//
//  Created by Kanz on 31/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit

class LanguageListCellReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var language: Language
        var isFavorite: Bool
    }
    
    let initialState: State
    
    init(language: Language, isFavorite: Bool) {
        self.initialState = State(language: language, isFavorite: isFavorite)
    }
}
