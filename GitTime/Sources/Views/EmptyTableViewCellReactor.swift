//
//  EmptyTableViewCellReactor.swift
//  GitTime
//
//  Created by Kanz on 20/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class EmptyTableViewCellReactor: Reactor {
    
    typealias Action = NoAction
    
    enum Mutation { }
    
    struct State {
        let type: EmptyTypes
    }
    
    let initialState: State
    
    init(type: EmptyTypes) {
        self.initialState = State(type: type)
        _ = self.state
    }
}
