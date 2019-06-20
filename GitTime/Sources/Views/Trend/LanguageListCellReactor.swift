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
    }
    
    let initialState: State
    
    init(language: Language) {
        self.initialState = State(language: language)
        _ = self.state
    }
}
