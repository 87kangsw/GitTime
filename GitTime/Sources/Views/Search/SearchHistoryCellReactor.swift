//
//  SearchHistoryCellReactor.swift
//  GitTime
//
//  Created by Kanz on 05/10/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit

class SearchHistoryCellReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var history: SearchHistory
    }
    
    let initialState: State
    
    init(history: SearchHistory) {
        self.initialState = State(history: history)
        _ = self.state
    }
}
