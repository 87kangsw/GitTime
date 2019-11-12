//
//  FollowUserCellReactor.swift
//  GitTime
//
//  Created by Kanz on 04/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit

class FollowUserCellReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var followUser: User
    }
    
    let initialState: State
    
    init(user: User) {
        self.initialState = State(followUser: user)
        _ = self.state
    }
}
