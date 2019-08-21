//
//  SearchUserCellReactor.swift
//  GitTime
//
//  Created by Kanz on 03/08/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit

class SearchUserCellReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var user: User
    }
    
    let initialState: State
    
    init(user: User) {
        self.initialState = State(user: user)
        _ = self.state
    }
}
