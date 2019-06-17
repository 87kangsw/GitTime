//
//  ContributionCellReactor.swift
//  GitTime
//
//  Created by Kanz on 17/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class ContributionCellReactor: Reactor {
    
    typealias Action = NoAction
    
    enum Mutation { }
    
    struct State {
        var contribution: Contribution
    }
    
    let initialState: State
    
    init(contribution: Contribution) {
        self.initialState = State(contribution: contribution)
        _ = self.state
    }
}
