//
//  ActivityItemCellReactor.swift
//  GitTime
//
//  Created by Kanz on 10/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class ActivityItemCellReactor: Reactor {
    
    typealias Action = NoAction
    
    enum Mutation { }
    
    struct State {
        var event: Event
    }
    
    let initialState: State
    
    init(event: Event) {
        self.initialState = State(event: event)
        _ = self.state
    }
    
}
