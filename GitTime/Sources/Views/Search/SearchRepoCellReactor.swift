//
//  SearchRepoCellReactor.swift
//  GitTime
//
//  Created by Kanz on 10/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit

class SearchRepoCellReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var repo: Repository
    }
    
    let initialState: State
    
    init(repo: Repository) {
        self.initialState = State(repo: repo)
        _ = self.state
    }
}
